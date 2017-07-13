
var resourceEditURL = "FormEditResource.html?identifier=";
var resourceCopyURL = "FormEditResource.html?copy=true&identifier=";
var resourceNewURL = "FormEditResource.html";
var manageResourceURL = "IngestResource.asmx/SetMyResourceStatus?identifier=$1&status=$2";
var uploadResourceURL = "IngestResource.asmx/IngestXMLResource";
var baseDirectoryURL = "http://vaodev.stsci.edu/directory/";

var storeResourceInfo = Ext.create('Ext.data.Store', {
    autoLoad: true,
    fields: ['title', 'shortName', 'identifier', 'status', 'updated', 'type'],
    sortOnLoad: true,
    sorters: { property: 'updated', direction : 'ASC' },
    proxy: {
        type: 'ajax',
        url: '../publishing/GetResourceInfo.asmx/GetMyResourcesList',
        reader: {
            type: 'json',
            root: 'ResourceInfo'
        },
        failure: function (result, request) {
            Ext.Msg.alert('Failed', result.responseText);
            myResources = null;
        },
        listeners: {
            exception: function (proxy, response, operation) {
                Ext.Msg.alert('Error', 'Error loading resource information from registry: ' + response.statusText);
            }
        }

    },
    storeId: 'storeResourceInfo',
    root: 'ResourceInfo'
});

getAuthInfo = function () {
    Ext.Ajax.request({
        url: PublishingWizard.LoginContainer.authinfoUrl,
        method: 'GET',
        success: function (result, request) {
            var json = Ext.decode(result.responseText);
            if (json && json.success == true) {
                if (json.message != undefined && json.message.length > 0) {
                    Ext.MessageBox.show({
                        title: 'No Organisation Information',
                        msg: 'No other resources can be created or edited until you have created an IVOA record for your organisation using your existing authority record. You may do so by selecting "Yes" below.',
                        buttons: Ext.MessageBox.YESNO,
                        closable: false,
                        buttonText: {
                            yes: 'Create New Organisation',
                            no: 'Cancel'
                        },
                        fn: function (btn, text) {
                            if (btn == 'no') {
                                var redirect = 'intro.html';
                                window.location = redirect;
                            }
                            else {
                                var redirect = 'FormEditResource.html';
                                window.location = redirect;
                            }
                        }
                    });
                }
                else if (json.defaultauth == undefined || json.defaultauth.length == 0) {
                    Ext.MessageBox.show({
                        title: 'No User Authority Information',
                        msg: 'No resources can be created or edited until an IVOA authority has been associated with this user account. ' +
                    'If you are associated with an existing IVOA institution and would like to edit or create new records under their authority, please contact helpdesk@usvao.org for assistance in completing account setup. ' +
                    'If you are a new user not belonging to an existing IVOA institution and would like to create your own IVOA records for your organisation and naming authority, you may do so by selecting "Yes" below. ' +
                    'One form entry of your organisational data will generate two records, one for the organisation itself and a second representing the "naming authority", used for curational purposes within the IVOA system of registries.',
                        buttons: Ext.MessageBox.YESNO,
                        closable: false,
                        buttonText: {
                            yes: 'Create New Authority',
                            no: 'Cancel'
                        },
                        fn: function (btn, text) {
                            if (btn == 'no') {
                                var redirect = 'intro.html';
                                window.location = redirect;
                            }
                            else {
                                var redirect = 'FormEditResource.html';
                                window.location = redirect;
                            }
                        }
                    });
                }
                else { //if (json.details.length > 0 && json.message.length == 0) {
                    Ext.getCmp('newResourceButton').enable();
                    Ext.getCmp('fileFormButton').enable();
                }
            }
        },
        failure: function (result, request) {
            Ext.Msg.alert('Error', 'Timeout loading authorization information', function (btn, text) {
                if (btn == 'ok') {
                    window.location = resourceManagementURL;
                }
            })
        }
    })
};


var selectedItem = null;
var sm = new Ext.selection.CheckboxModel({
    mode: 'single',
    allowDeselect: true,
    listeners: {
        selectionchange: function (selectionModel, selected, options) {
            selectedItem = selected;
            if (selectedItem.length == 0 || selectedItem[0].raw.status == 'deleted') {
                Ext.getCmp('selectionButton').disable();
                Ext.getCmp('deletionButton').disable();
                Ext.getCmp('copyButton').disable();

                Ext.getCmp('activationButton').disable();
                Ext.getCmp('activationButton').show();
                Ext.getCmp('deactivationButton').hide();
            }
            else {
                Ext.getCmp('selectionButton').enable();
                Ext.getCmp('deletionButton').enable();
                Ext.getCmp('copyButton').enable();

                if (selectedItem[0].raw.status == 'inactive') {
                    Ext.getCmp('activationButton').enable();
                    Ext.getCmp('activationButton').show();
                    Ext.getCmp('deactivationButton').hide();
                }
                else if (selectedItem[0].raw.status == 'active') {
                    Ext.getCmp('deactivationButton').enable();
                    Ext.getCmp('deactivationButton').show();
                    Ext.getCmp('activationButton').hide();
                }
                else if (selectedItem[0].raw.status == 'PENDING') {
                    Ext.getCmp('activationButton').hide();
                    Ext.getCmp('deactivationButton').hide();
                }
            }
        }
    }
});

redirectForEdit = function (identifier, status) {
    var redirect = resourceNewURL;
    if (identifier != "")
        redirect = resourceEditURL + identifier;

    window.location = redirect;
};

redirectForCopy = function (identifier, status) {
    var redirect = resourceNewURL;
    if (identifier != "")
        redirect = resourceCopyURL + identifier;

    window.location = redirect;
};

reloadStore = function (grid) {
    grid.store = store;
    store.load();
    grid.getView().refresh();
}

uploadResource = function (fb, f) {

    if (Ext.getCmp('uploadForm').getForm().isValid()) {
        form_action = 1;
        Ext.getCmp('uploadForm').getForm().submit({
            method: 'POST',
            fileUpload: true,
            waitMsg: 'Uploading file...',
            success: function (form, action) {
                var text = action.response.responseText;
                var json = Ext.decode(action.response.responseText);
                Ext.Msg.alert('Success', json.details);
                reloadStore(Ext.getCmp('resourcesGrid'));
            },
            failure: function (form, action) {
                var text = action.response.responseText;
                var json = Ext.decode(action.response.responseText);
                if (json && json.details != undefined) {
                    Ext.Msg.alert('Error', 'Failed to upload and process your XML resource file: ' + json.details, function (btn, text) {
                    });
                }
                else {
                    Ext.Msg.alert('Error', 'Failed to upload and process your XML resource file.');
                }
            }
        });
    }
};

manageResource = function (status, row) {
    var identifier = row.raw.identifier;

    if (identifier != "") {
        Ext.Ajax.request({
            url: manageResourceURL.replace('$1', identifier).replace('$2', status),
            method: 'GET',
            success: function (result, request) {
                var json = Ext.decode(result.responseText);
                if (json.success == true) {
                    if (status.indexOf('delete') > -1) {
                        Ext.Msg.alert('Success', 'Resource successfully deleted.');
                        storeResourceInfo.remove(row);
                    }
                    else {
                        Ext.Msg.alert('Success', 'Resource status changed.');
                        if (status.indexOf('inactiv') > -1) {
                            row.set('status', 'inactive');
                            row.raw.status = 'inactive';
                            Ext.getCmp('activationButton').enable();
                            Ext.getCmp('activationButton').show();
                            Ext.getCmp('deactivationButton').hide();
                        }
                        else if (status.indexOf('activ') > -1) {
                            row.set('status', 'active');
                            row.raw.status = 'active';
                            Ext.getCmp('deactivationButton').enable();
                            Ext.getCmp('deactivationButton').show();
                            Ext.getCmp('activationButton').hide();
                        }
                    }
                    reloadStore(Ext.getCmp('resourcesGrid'));
                }
                else
                    Ext.Msg.alert('Error', 'Failed to change resource status: ' + json.errors.reason);
            },
            failure: function (result, request) {
                if (status == 'deleted')
                    Ext.Msg.alert('Failed to delete resource. ', result.responseText);
                else
                    Ext.Msg.alert('Failed to change resource status: ' + result.responseText);
            }
        })
    }
};

Ext.define('PublishingWizard.fileUpload', {
    extend: 'Ext.form.field.File',
    alias: 'widget.file'
});

Ext.define('PublishingWizard.ManagementLayout', {
    extend: 'Ext.panel.Panel',

    statics: {},

    constructor: function (config) {
        var me = this;

        // Apply mandatory config items.       
        Ext.apply(config, {
            border: 0,
            layout: 'fit',
            name: 'centerViewport',
            id: 'centerViewport',
            bodyStyle: 'background: transparent;',
            width: 1000,
            autoScroll: false,
            defaults: {
                autoScroll: 'true',
                autoHeight: 'true',
                layout: 'fit'
            },
            items: [{
                xtype: 'form',
                id: 'uploadForm',
                layout: 'hbox',
                method: 'POST',
                border: 0,
                margin: '10 0 0 10',
                bodyStyle: 'background: transparent;',
                url: uploadResourceURL,
                items: [{
                    xtype: 'button',
                    width: 150,
                    maxWidth: 150,
                    id: 'newResourceButton',
                    text: 'Create New Resource',
                    disabled: true,
                    handler: function () { redirectForEdit() }
                }
                , {
                     xtype: 'file',
                     buttonOnly: true,
                     hideLabel: true,
                     buttonText: 'Upload XML Resource File',
                     id: 'fileFormButton',
                     disabled: true,
                     buttonConfig: { width: 150 },
                     listeners: {
                         'change': function (fb, v) { uploadResource(fb, v); }
                     }
                 }
                , {
                    height: 20,
                    width: 650,
                    border: 0,
                    margin: '0 0 0 10',
                    bodyStyle: 'background: transparent;',
                    autoEl: { tag: 'h3', html: '...or select an existing resource below to edit, delete, or use as a template for a new resource.' }
                }
                ]
            },
            {
                xtype: 'grid',
                store: storeResourceInfo,
                title: 'My Resources',
                id: 'resourcesGrid',
                autoScroll: true,
                minHeight: 200,
                width: 980,
                maxWidth: 980,
                selModel: sm,
                margin: 10,
                layout: 'fit',
                forceFit: true,
                columns: [
                    {
                        text: 'Title',
                        width: 300,
                        hideable: false,
                        dataIndex: 'title'
                    },
                    {
                        text: 'Short Name',
                        dataIndex: 'shortName',
                        hideable: false
                    },
                    {
                        text: 'Identifier',
                        width: 175,
                        dataIndex: 'identifier',
                        hideable: false
                    },
                    {
                        text: 'Last Updated (UTC)',
                        width: 130,
                        dataIndex: 'updated',
                        hideable: false
                    },
                    {
                        text: 'Status',
                        width: 75,
                        dataIndex: 'status',
                        hideable: false
                    },
                    {
                        text: 'Service Type(s)',
                        dataIndex: 'type',
                        hideable: false
                    },
                    {
                        text: 'Pending File',
                        dataIndex: 'file',
                        hideable: true,
                        hidden: true
                    },
                    {
                        width: 80,
                        maxWidth: 80,
                        text: 'Preview',
                        dataIndex: 'identifier',
                        sortable: false,
                        renderer: function (val, meta, record) {
                            if (record.get('status') == 'PENDING')
                                return '';
                            else
                                return '<a href="' + baseDirectoryURL + 'getRecord.aspx?id=' + val + '" target="_blank">' + 'Preview' + '</a>';

                        }
                    }]
            },
            {
                xtype: 'button',
                id: 'selectionButton',
                margin: '0 0 0 10',
                width: 150,
                maxWidth: 150,
                disabled: 'true',
                text: 'Edit Selected Resource',
                handler: function () { redirectForEdit(selectedItem[0].raw.identifier, selectedItem[0].raw.status) }
            },
            {
                xtype: 'button',
                width: 150,
                maxWidth: 150,
                id: 'copyButton',
                disabled: 'true',
                text: 'Clone Selected Resource',
                handler: function () { redirectForCopy(selectedItem[0].raw.identifier, selectedItem[0].raw.status) }
            },
            {
                xtype: 'button',
                id: 'deletionButton',
                width: 150,
                maxWidth: 150,
                disabled: 'true',
                text: 'Delete Selected Resource',
                handler: function () {
                    var msg = 'Are you sure you want to delete ' + selectedItem[0].raw.identifier +
                              ' ? Deleted resources will no longer show up in registry search results, and should not be republished later using the same identifier. If necessary, their data can be recovered by contacting the help desk at archive@stsci.edu. Updates may take up to 24h to show in MAST registry search results.';
                    if (selectedItem[0].raw.status && selectedItem[0].raw.status == "PENDING") {
                        msg = 'Are you sure you want to delete the pending resource ' + selectedItem[0].raw.identifier +
                              ' ? Deleted pending resources will no longer be accessible for editing. If necessary, their data can be recovered by contacting the help desk at archive@stsci.edu.';
                    }
                    Ext.MessageBox.confirm('Confirm', msg, function (btn) { if (btn == 'yes') { manageResource('deleted', selectedItem[0]); } })
                }
            },
            {
                xtype: 'button',
                id: 'activationButton',
                width: 250,
                maxWidth: 250,
                disabled: 'true',
                text: 'Activate Selected Resource',
                handler: function () {
                    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to activate ' + selectedItem[0].raw.identifier +
                                            ' ? Active resources will show up in registry search results. Updates may take up to 24h to show in MAST registry search results.', function (btn) {
                                                if (btn == 'yes') { manageResource('active', selectedItem[0]); }
                                            })
                }
            },
            {
                xtype: 'button',
                id: 'deactivationButton',
                width: 250,
                maxWidth: 250,
                disabled: 'true',
                hidden: 'true',
                text: 'Deactivate Selected Resource',
                handler: function () {
                    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to deactivate ' + selectedItem[0].raw.identifier +
                                            ' ? Deactivated resources will not show up in registry search results, but will not be deleted. ' +
                                            'This is useful if your resource describes a service experiencing long-term downtime. Updates may take up to 24h to show in MAST registry search results.', function (btn) {
                                                if (btn == 'yes') { manageResource('inactive', selectedItem[0]); }
                                            })
                }
            }] //centerpanel items
        }); //viewport

        // Apply defaults for config.       
        Ext.applyIf(config, {});

        this.callParent([config]);
        this.centerPanel = Ext.getCmp('centerViewport');
        Ext.getCmp('newResourceButton').focus(false, 100);

        getAuthInfo();
    }
});