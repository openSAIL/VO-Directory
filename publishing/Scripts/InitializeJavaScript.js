/**
 * Load the library located at the same path with this file
 *
 * Will automatically load ext-all-debug.js if any of these conditions is true:
 * - Current hostname is localhost
 * - Current hostname is an IP v4 address
 * - Current protocol is "file:"
 *
 * Will load ext-all.js (minified) otherwise
 */
(function() {

    var scripts = document.getElementsByTagName('script'),
        localhostTests = [
            /^localhost$/,
            /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(:\d{1,5})?\b/ // IP v4
        ],
        host = window.location.hostname,
        queryString = window.location.search,
        test, path, i, ln, scriptSrc, match;

    /* extPath = "http://galextest.stsci.edu/test/extjs/4.0.2/";*/
    extPath = "http://vaotest.stsci.edu/publishing/scripts/extjs4/";
    
    for (i = 0, ln = scripts.length; i < ln; i++) {
        scriptSrc = scripts[i].src;
    
        match = scriptSrc.match(/InitializeJavaScript\.js$/);
    
        if (match) {
            initializationPath = scriptSrc.substring(0, scriptSrc.length - match[0].length);
            break;
        }
    }

    isDevelopment = null;
    if (queryString.match('(\\?|&)debug') !== null) {
        isDevelopment = true;
    }
    else if (queryString.match('(\\?|&)nodebug') !== null) {
        isDevelopment = false;
    }

    if (isDevelopment === null) {
        for (i = 0, ln = localhostTests.length; i < ln; i++) {
            test = localhostTests[i];

            if (host.search(test) !== -1) {
                isDevelopment = true;
                break;
            }
        }
    }

    if (isDevelopment === null && window.location.protocol === 'file:') {
        isDevelopment = true;
    }
    //isDevelopment = false;
    
    // Enable the use of a remote server during client development.
    mashupURLOverride = undefined;
    if (window.location.protocol === 'file:') {
	// The html was loaded from a local file, so we will assume the developer wants to use a remote server.
	mashupURLOverride = 'http://vaodev.stsci.edu/portal/Mashup/Mashup.asmx/invoke';
    } 

    var filestr = window.location.href;
    var cssBasePath = extPath + 'resources/';
    //var cssBasePath = '';
    
    document.write('<link rel="stylesheet" type="text/css" href="' + extPath + 'resources/css/ext-all.css" />');
    //document.write('<link rel="stylesheet" type="text/css" href="' + extPath + 'examples/shared/example.css" />');

    document.write('<script type="text/javascript" src="' + extPath + 'ext-all' + ((isDevelopment) ? '-dev' : '') + '.js"></script>');
    //document.write('<script type="text/javascript" src="' + initializationPath + 'InitializeLocal.js"></script>');
    
})();
