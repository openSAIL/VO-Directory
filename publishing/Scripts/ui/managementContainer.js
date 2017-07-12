﻿/*
 * File: app/view/ui/ManagementContainer.js
 * Date: Thu Mar 12 2015 14:36:14 GMT-0400 (EDT)
 *
 * This file was generated by Ext Designer version 1.2.3.
 * http://www.sencha.com/products/designer/
 *
 * This file will be auto-generated each and everytime you export.
 *
 * Do NOT hand edit this file.
 */

Ext.define('PublishingWizard.ui.ManagementContainer', {
    extend: 'Ext.container.ButtonGroup',

    frame: false,
    id: 'idManagementContainer',
    cls: 'itemManagementContainer',
    itemId: 'itemManagementContainer',
    columns: 1,

    initComponent: function () {
        var me = this;

        Ext.applyIf(me, {
            layout: {},
            items: [
                {
                    xtype: 'button',
                    id: 'idManagementButton',
                    itemId: 'itemManagementButton',
                    disabled: true,
                    margin: 1,
                    focusOnToFront: false,
                    text: 'Mange My Resources'
                }
            ]
        });

        me.callParent(arguments);
    }
});