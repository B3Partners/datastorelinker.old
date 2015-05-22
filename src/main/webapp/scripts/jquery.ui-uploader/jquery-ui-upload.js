/**
 * jQueryUI-Uplad v1.1.0
 * Release Date: 02. April 2010
 * Copyright:    (c) 2010 Michael Keck
 *
 * Based on Code from the project 'jQuery-Uploadify'
 * made by Ronnie Garcia & Travis Nickels
 *
 * Requires     : * jQuery 1.4.2      http://jquery.com/
 *                * jQuery UI 1.8     http://jqueryui.com/
 *                * SWFObject 2.2     http://code.google.com/p/swfobject/
 *                * Current Flash     http://get.adobe.com/flashplayer/
 *                * Modern Browser    Tested on IE7, IE8, IE9 (Preview) and
 *                                    Firefox 3.6 (Windows)
 *                * Backend for Filehandling (php, asp, cgi, jsp ...)
 *
 * Depends      : * jquery core
 *                * jquery ui core
 *                * jquery ui buttons
 *                * jquery ui progressbar
 */

(function($) {

    function _filetypes(v) {
        var r = '';
        if (v) {
            for (var k in v) {
                r += ';' + k + ':' + v[k].join(',');
            }
            r = r.substr(1);
        }
        return r;
    };

    function _fileinfo(o, d) {
        var fn = o.fname, fs = o.fsize, ft = '', su = 'KiB', si = '<acronym title="Kilobytes (1 KiB = 1024 Bytes)">KiB</acronym>', sp = [];
        fs = Math.round(fs / 1024);
        if (fs > 1024) {
            fs = Math.round(fs / 1024);
            su = 'KiB', si = '<acronym title="Megabytes (1 MiB = 1024 Kilobytes)">MiB</acronym>';
        }
        sp = fs.toString().split('.');
        if (sp.length > 1) {
            fs = sp[0] + '.' + sp[1].substring(0, 2);
        } else {
            fs = sp[0];
        }
        ft = fn.substr(fn.lastIndexOf('.'), fn.length);
        ns = fn.substr(0, fn.lastIndexOf('.'));
        if (ns.length > 20) {
            ns = ns.substr(0, 20) + ' ... ' + ft;
        } else {
            ns = ns.substr(0, 20) + ft;
        }
        return { 'name': ns, 'nameinfo': fn, 'size': fs, 'sizeunit': su, 'sizeinfo': si };
    };

    var swfSuffix = 'SWF';
    $.extend($.fn, {

        uiload : function(options, language) {

            $(this).each(function() {
                var opts = $.extend({
                    auto            : true,
                    btnIcon         : true,                       // Display Icons in Buttons
                    btnStart        : true,                       // Display Upload Button
                    btnStartClick   : true,                       // Start Upload on Click
                    btnStop         : true,                       // Display Cancel Button
                    btnStopClick    : true,                       // Stop Upload on Click
                    swfaccess       : 'sameDomain',               // Set to "always" to allow script access across domains
                    swfinstaller    : null,                       // The path to the express install swf file
                    swfuploader     : 'swf/jquery-ui-upload.swf', // The path to the uiload swf file
                    script          : 'jquery-ui-upload.php',     // The path to the uiload backend upload script
                    scriptData      : null,                       // ScriptData
                    checkScript     : null,                       // The path to the uiload backend upload script
                    checkScriptData : null,                       // ScriptData
                    // EvdP: added options: checkScriptAjaxOptions, fadeOut, progressValueColor
                    checkScriptAjaxOptions : {},                  // regular ajaxOptions to use with the checkScript ajax call
                    fadeOut         : true,                       // fadeOut progressbar after upload complete?
                    progressValueColor : null,                    // text color of progress value percentage.
                    overwrite       : false,
                    fpath           : '',                         // The path to the upload folder
                    rename          : '',                         // The file Name
                    fdata           : 'uploads',                  // The name of the file collection object in the backend upload script
                    ftypes          : {                           // The Filetypes
					    'JPEG Image' : ['jpg', 'jpe', 'jpeg'],
                        'PNG Image' : 'png',
                        'GIF Image' : 'gif'
				    },
                    method          : 'POST',                     // The method for sending variables to the backend upload script
                    maxfiles        : 5,                          // The maximum size of the file queue
                    maxfilesize     : 1048576, // 104857600,                   // The maximum filesize each file
                    simultan        : 1,                          // The number of simultaneous uploads allowed

                    onSelect        : function() {},              // Function to run when a file is selected
                    // onSelectOnce    : function() {},
                    onMaxFiles      : function() {},              // Function to run when the queue reaches capacity
                    onCheck         : function() {},              // Function to run when script checks for duplicate files on the server
                    onCancel        : function() {},              // Function to run when an item is cleared from the queue
                    onClear         : function() {},              // Function to run when the queue is cleared
                    onError         : function() {},              // Error Function
                    onProgress      : function() {},              // Function to run each time the upload progress is updated
                    onComplete      : function() {},              // Function to run when an upload is completed
                    onFinished      : function() {}               // Functino to run when all uploads are completed
                }, options);

                /**
                 * STRINGS
                 * ------------------------------------------------------------------
                 */
                var locale = $.extend({
                    browse:          'Durchsuchen ...',
                    submitfile:      'Datei hochladen',
                    submitfiles:     'Dateien hochladen',
                    cancel:          'Abbrechen',
                    completed:       'Fertig',
                    error:           'Fehler',
                    errorfiletype:   'Die Datei {file} ist vom Typ {mimetype} und wird vom System nicht unterst\u00FCtzt.',
                    errorfilesize:   'Die Datei {file} ist zu gro\u00DF. Die maximale erlaubte Dateigr\u00F6\u00DFe betr\u00E4gt {file_size}.',
                    errorfileexist:  'Die Datei {file} existiert bereits.',
                    errorfileupload: 'Die Datei {file} konnte nicht \u00FCbertragen werden.',
                    no:              'Nein',
                    notice:          'Hinweis',
                    ok:              'Ok',
                    overwrite:       'Die Datei {file} ist bereits vorhanden.\nWollen Sie die Datei {file} wirklich mit der neuen Datei \u00FCberschreiben?',
                    remove:          'Datei entfernen',
                    queuefull:       'Die Warteschlange f\u00FCr Uploads ist voll.\nEs k\u00F6nnen maximal {files} in die Warteschlange aufgenommen werden.',
                    warning:         'Achtung',
                    yes:             'Ja'
                }, language);

                var wait = false;
                var uid = $(this).attr('id');
                var swf = uid + swfSuffix,
                    pagepath = location.pathname,
                    buttonStart = uid + 'Start',
                    buttonStop  = uid + 'Stop'
                    errorArray = [], countError = 0;
                var data = {
                    'swfid'          : uid,
                    'queueID'        : uid + 'Queue',
                    // Settings from User
                    'method'         : ( (opts.method && opts.method == 'GET') ? 'GET' : 'POST' ),
                    'maxfiles'       : ( !isNaN(parseInt(opts.maxfiles, 10))    ? parseInt(opts.maxfiles, 10) : 999 ),
                    'simultan'       : ( !isNaN(parseInt(opts.simultan, 10)) ? parseInt(opts.simultan, 10) : 1 ),
                    'maxsize'        : ( !isNaN(parseInt(opts.maxfilesize, 10)) ? parseInt(opts.maxfilesize, 10) : 8388608 )
                };

                pagepath = pagepath.split('/');
                pagepath.pop();
                pagepath = pagepath.join('/') + '/';

                data.pagepath = pagepath;
                data.script   = opts.script;
                data.fpath    = escape(opts.fpath);

                if (opts.scriptData) {
                    var scriptDataString = '';
                    for (var name in opts.scriptData) {
                        scriptDataString += '&' + name + '=' + opts.scriptData[name];
                        data[name] = opts.scriptData[name];
                    }
                    data.scriptData = escape(scriptDataString.substr(1));
                }
                if (opts.multi) {
                    data.multi = true;
                }
                if (opts.auto) {
                    data.auto = true;
                }
                if (opts.debug) {
                    // data.debug = true;
                }
                if (opts.checkScriptData) {
                    data.checkScript = opts.script;
                    if (opts.checkScript) {
                        data.checkScript = opts.checkScript;
                    }
                    data.simultan = 1;
                }
                if (opts.fdata) {
                    data.fdata = opts.fdata;
                }
                data.ftypes = _filetypes(opts.ftypes);
                data.rename = '';
                if (opts.rename) {
                    data.rename = opts.rename;
                    if (opts.renum) {
                        data.renum = opts.renum;
                    }
                }
                if (opts.fclass) {
                    data.fclass = opts.fclass;
                }

                $('#' + uid).css({ 'display' : 'none', 'visibility' : 'hidden' });
                $('#' + uid).after('<div class="ui-helper-reset ui-helper-clearfix ui-upload ui-corner-all" id="' + uid + 'Body"></div>');
                $('#' + uid + 'Body').append('<div class="ui-upload-buttonpane" id="' + uid + 'Panel"></div>');
                $('#' + uid + 'Panel').append('<a class="ui-upload-button-left" id="' + uid + 'Browse" href="#" onclick="return false;"></a>');
                $('#' + uid + 'Browse').css(
                    { 'position' : 'relative' }
                ).button({
                    'icons': {
                        'primary' : (opts.btnIcon ? 'ui-icon-folder-collapsed' : false)
                    },
                    'label': locale.browse
                }).append('<div class="ui-upload-flash" id="' + uid + 'Flash"><div id="' + swf + '"></div></div>');

                data.height = $('#' + uid + 'Browse').outerHeight();
                data.width  = $('#' + uid + 'Browse').outerWidth();

                if (opts.btnStart) {
                    if (typeof(opts.btnStart) == 'boolean' && opts.btnStart == true) {
                        $('#' + uid + 'Panel').append('<a class="ui-upload-button-right" href="#" id="' + uid + 'Start"></a>');
                        $('#' + buttonStart).button({
                            'icons': {
                                'primary' : (opts.btnIcon ? 'ui-icon-circle-check' : false)
                            },
                            'label' : ( (opts.maxfiles > 1) ? locale.submitfiles : locale.submitfile )
                        });
                    } else if (typeof(opts.btnStart) == 'string' && opts.btnStart !== '') {
                        buttonStart = opts.btnStart;
                    }
                    $('#' + buttonStart).addClass('ui-upload-start');
                    if (opts.btnStartClick) {
                        $('#' + buttonStart).click(function () {
                            $('#' + uid).uiloadUpload();
                            if (typeof(opts.btnStartClick) == 'function') {
                                opts.btnStartClick();
                            }
                            return false;
                        });
                    }
                }
                if (opts.btnStop) {
                    if (typeof(opts.btnStop) == 'boolean' && opts.btnStop == true) {
                        $('#' + uid + 'Panel').append('<a class="ui-upload-button-right" href="#" id="' + uid + 'Stop"></a>');
                        $('#' + buttonStop).button({
                            'icons': {
                                'primary' : (opts.btnIcon ? 'ui-icon-circle-close' : false)
                            },
                            'label' : locale.cancel
                        });
                    } else {
                        buttonStop = opts.btnStop;
                    }
                    $('#' + buttonStop).addClass('ui-upload-stop');
                    if (opts.btnStopClick) {
                        $('#' + buttonStop).click(function () {
                            $('#' + uid).uiloadClear();
                            if (typeof(opts.btnStopClick) == 'function') {
                                opts.btnStopClick();
                            }
                            return false;
                        });
                    }
                }
                $('#' + uid + 'Panel a').removeAttr('target').css({ 'outline' : 'none' });

                $('#' + uid + 'Flash').css({
                    'position' : 'absolute',
                    'left'     : '-1px',
                    'top'      : '-1px',
                    'zIndex'   : '999999',
                    'height'   : data.height,
                    'width'    : data.width
                });

                if (opts.queueAfter) {
                    $('#' + uid + 'Panel').after('<div id="' + data.queueID + '" class="ui-upload-queue"></div>');
                } else {
                    $('#' + uid + 'Panel').before('<div id="' + data.queueID + '" class="ui-upload-queue"></div>');
                }
                $('#' + data.queueID).addClass('ui-widget ui-widget-content ui-corner-all');

                // Create Flash
                $('#' + swf).flash({
                    'src':       opts.swfuploader + '?time=' + (new Date().getTime()),
                    'width':     data.width,
                    'height':    data.height,
                    'flashvars': data
                });

                $('#' + swf).hover(
                    function() { $('#' + uid + 'Browse').removeClass('ui-state-default').addClass('ui-state-hover'); },
                    function() { $('#' + uid + 'Browse').removeClass('ui-state-hover').addClass('ui-state-default'); }
                );

                if (typeof(opts.onClear) == 'function') {
                    $(this).bind('clear', opts.onClear);
                }
                if (typeof(opts.onFinished) == 'function') {
                    $(this).bind('finished', { 'action' : opts.onFinished }, function(event, uploadObj) {
                        if (event.data.action(event, uploadObj) !== false) {
                            errorArray = [];
                            wait = false;
                        }
                    });
                }
                if (typeof(opts.onOpen) == 'function') {
                    $(this).bind('open', opts.onOpen);
                }
                if (typeof(opts.onSelectOnce) == 'function') {
                    $(this).bind('selectonce', opts.onSelectOnce);
                }

                $(this).bind('cancel', { 'action': opts.onCancel }, function(event, ID, fileObj, data, clearFast) {
                    if (event.data.action(event, ID, fileObj, data, clearFast) !== false) {
                        var fadeSpeed = (clearFast == true) ? 0 : 250;
                        $("#" + uid + ID).fadeOut(fadeSpeed, function() { $(this).remove() });
                        wait = false;
                    }
                }).bind('check', { 'action': opts.onCheck }, function(event, checkScript, fileObj, fileDir, single) {
                    var sd = {}, err = false;
                    // EvdP: Commented out:
                    //sd = fileObj;

                    // EvdP: produce some proper JSON:
                    var jsonList = [];
                    for (var q in fileObj[opts.fdata])
                        jsonList.push(fileObj[opts.fdata][q]);
                    //log(jsonList);
                    sd.status = JSON.stringify(jsonList[0]);

                    sd.fpath = pagepath + fileDir;
                    if (opts.maxsize) {
                        sd.maxsize = opts.maxsize;
                    }
                    if (opts.checkScriptData) {
                        for (var k in opts.checkScriptData) {
                            sd[k] = opts.checkScriptData[k];
                        }
                    }
                    if (single) {
                        var sid = fileObj.ID;
                    }
                    // only use ajaxOptions from the user that do not interfere with our defaults:
                    $.ajax($.extend({}, opts.checkScriptAjaxOptions, {
                        url: checkScript,
                        data: sd,
                        type: "POST",
                        dataType: "json",
                        success: function(data) {
                            for (var k in data) {
                                if (event.data.action(event, checkScript, fileObj, fileDir, single) !== false) {
                                    switch(data[k].errtype) {
                                        case 'exists':
                                            event.stopImmediatePropagation();
                                            if (opts.overwrite) {
                                                var s = locale.overwrite.replace(/{file}/gi, data[k].fname);
                                                if ($.confirm && opts.maxfiles < 2) {
                                                    err = true;
                                                    $.confirm({
                                                        'title'    : locale.notice.replace('\n', ' '),
                                                        'text'     : s.replace('\n', '<br />'),
                                                        'onclose'  : null,
                                                        'cssclass' : 'ui-dialog-confirm',
                                                        'width'    : 300,
                                                        'height'   : 150,
                                                        'ontrue'   : function () { document.getElementById(swf).loadFile(data[k].ID, true); err = false; },
                                                        'onfalse'  : function () { document.getElementById(swf).cancelFile(data[k].ID, true, true); err = false; }
                                                    });
                                                } else {
                                                    if (!confirm(s)) {
                                                        document.getElementById(swf).cancelFile(data[k].ID, true, true);
                                                    }
                                                }
                                            } else {
                                                var s = locale.errorfileexist.replace(/{file}/gi, data[k].fname);
                                                if ($.alert && opts.maxfiles < 2) {
                                                    err = true;
                                                    $.alert({
                                                        'title'    : locale.error.replace('\n', ' '),
                                                        'text'     : s.replace('\n', '<br />'),
                                                        'onclose'  : function() { document.getElementById(swf).cancelFile(data[k].ID, true, true); err = false; },
                                                        'cssclass' : 'ui-dialog-error',
                                                        'width'    : 300,
                                                        'height'   : 120
                                                    });
                                                } else {
                                                    alert(s);
                                                    document.getElementById(swf).cancelFile(data[k].ID, true, true);
                                                }
                                            }
                                            break;
                                        case 'type':
                                            event.stopImmediatePropagation();
                                            var s = locale.errorfiletype;
                                            s = s.replace(/{file}/gi, data[k].fname);
                                            s = s.replace(/{mimetype}/gi, data[k].ftype.toUpperCase());
                                            if ($.alert && opts.maxfiles < 2) {
                                                err = true;
                                                $.alert({
                                                    'title'    : locale.error.replace('\n', ' '),
                                                    'text'     : s.replace('\n', '<br />'),
                                                    'onclose'  : function() { document.getElementById(swf).cancelFile(data[k].ID, true, true); err = false; },
                                                    'cssclass' : 'ui-dialog-error',
                                                    'width'    : 300,
                                                    'height'   : 120
                                                });
                                            } else {
                                                alert(s);
                                                document.getElementById(swf).cancelFile(data[k].ID, true, true);
                                            }
                                            break;
                                        case 'size':
                                            event.stopImmediatePropagation();
                                            var x = _fileinfo(data[k]), s = locale.errorfilesize;
                                            s = str.replace(/{file}/gi, x.name);
                                            s = str.replace(/{file_size}/gi, x.size + ' ' + x.sizeunit);
                                            if ($.alert && opts.maxfiles < 2) {
                                                err = true;
                                                $.alert({
                                                    'title'    : locale.error.replace('\n', ' '),
                                                    'text'     : s.replace('\n', '<br />'),
                                                    'onclose'  : function() { document.getElementById(swf).cancelFile(data[k].ID, true, true); err = false; },
                                                    'cssclass' : 'ui-dialog-error',
                                                    'width'    : 300,
                                                    'height'   : 120
                                                });
                                            } else {
                                                alert(s);
                                                document.getElementById(swf).cancelFile(data[k].ID, true, true);
                                            }
                                            break;
                                        case 'none': // No error
                                            document.getElementById(swf).loadFile(data[k].ID, true);
                                            break;
                                        default:
                                            event.stopImmediatePropagation();
                                            var s = locale.errorfileupload;
                                            s = str.replace(/{file}/gi, data[k].fname);
                                            if ($.alert && opts.maxfiles < 2) {
                                                err = true;
                                                $.alert({
                                                    'title'    : locale.error.replace('\n', ' '),
                                                    'text'     : s.replace('\n', '<br />'),
                                                    'onclose'  : function() { document.getElementById(swf).cancelFile(data[k].ID, true, true); err = false; },
                                                    'cssclass' : 'ui-dialog-error',
                                                    'width'    : 300,
                                                    'height'   : 120
                                                });
                                            } else {
                                                alert(s);
                                                document.getElementById(swf).cancelFile(data[k].ID, true, true);
                                            }
                                            break;
                                    }
                                }
                            }
                            //if (!err) {
                            //    if (single) {
                            //        document.getElementById(swf).loadFile(sid, true);
                            //    } else {
                            //        document.getElementById(swf).loadFile(null, true);
                            //    }
                            //}
                        }
                    }));
                }).bind('complete', { 'action' : opts.onComplete }, function(event, fileID, fileObj, response, data) {
                    if (event.data.action(event, fileID, fileObj, unescape(response), data) !== false) {
                        $('#' + uid + fileID + 'ProgressValue').css({ 'width' : data.percentage + '%' });
                        $('#' + uid + fileID + 'ProgressLabel').text(data.percentage + '%' + ' (' + data.speed + ' KB/s)');
                        // $('#' + uid + fileID).addClass('ui-state-success');
                        if (opts.fadeOut)
                            $('#' + uid + fileID).addClass('ui-state-disabled');
                        $('#' + uid + fileID + 'ProgressText').text(' - ' + locale.completed);
                        setTimeout(function() {
                            if (opts.fadeOut) // option added: EvdP
                                $('#' + uid + fileID).fadeOut('slow', function() { $(this).remove(); });
                            wait = false;
                        }, 2000);
                    }
                }).bind('error', { 'action': opts.onError }, function(event, fileID, fileObj, errorObj) {
                    if (event.data.action(event, fileID, fileObj, errorObj) !== false) {
                        var fileArray = new Array(fileID, fileObj, errorObj), s = locale.errorfileupload.replace(/{file}/gi, fileObj.fname);
                        errorArray.push(fileArray);
                        $('#' + uid + fileID + 'ProgressText').text(' - '  + locale.error + ': ' + errorObj.type);
                        $('#' + uid + fileID).addClass('ui-state-error');
                        event.stopImmediatePropagation();
                        if ($.alert && opts.maxfiles < 2) {
                            $.alert({
                                'title'    : locale.error.replace('\n', ' '),
                                'text'     : s.replace('\n', '<br />'),
                                'onclose'  : function() { document.getElementById(swf).cancelFile(fileObj.ID, true, true); },
                                'cssclass' : 'ui-dialog-error',
                                'width'    : 300,
                                'height'   : 120
                            });
                        } else {
                            alert(s);
                            document.getElementById(swf).cancelFile(fileObj.ID, true, true);
                        }
                    }
                }).bind('maxfiles', { 'action': opts.onMaxFiles }, function(event, maxfiles) {
                    if (event.data.action(event, maxfiles) !== false) {
                        var str = locale.queuefull;
                        str = str.replace('{files}', opts.maxfiles);
                    }
                }).bind('progress', { 'action' : opts.onProgress }, function(event, fileID, fileObj, data) {
                    if (event.data.action(event, fileID, fileObj, data) !== false) {
                        $('#' + uid + fileID + 'ProgressValue').css({ 'width' : data.percentage + '%' });
                        $('#' + uid + fileID + 'ProgressLabel').text(data.percentage + '%' + ' (' + data.speed + ' KB/s)');
                        if (data.percentage >= 100 && typeof(document.body.style.maxHeight) == 'undefined') {
                            // Fix for old terrible IE6
                            $('#' + uid + fileID).addClass('ui-state-success');
                            if (opts.fadeOut)
                                $('#' + uid + fileID).addClass('ui-state-disabled');
                            $('#' + uid + fileID + 'ProgressText').text(' - ' + locale.completed);
                            setTimeout(function() {
                                if (opts.fadeOut) // option added: EvdP
                                    $('#' + uid + fileID).fadeOut('slow', function() { $(this).remove(); });
                                wait = false;
                            }, 2000);
                        }
                    }
                }).bind('select', { 'action': opts.onSelect, 'queueID': data.queueID }, function(event, fileID, fileObj) {
                    if (event.data.action(event, fileID, fileObj) !== false) {
                        var x = _fileinfo(fileObj);
                        $('#' + data.queueID).append(''
                            + '<div id="' + uid + fileID + '" class="ui-upload-item ui-widget-content ui-corner-all">'
                              + ( (opts.maxfiles > 1) ? '<a class="ui-icon ui-icon-circle-minus" onclick="jQuery(\'#' + uid + '\').uiloadCancel(\'' + fileID + '\')" title="' + locale.remove + '">' + locale.remove + '</a>' : '' )
                              + '<div class="ui-upload-label">'
                                + '<span title="' + x.nameinfo + '">' + x.name + ' <em>(' + x.size + x.sizeinfo + ')</em></span>'
                                + '<span id="' + uid + fileID + 'ProgressText"></span>'
                              + '</div>'
                              + '<div id="' + uid + fileID + 'ProgressBar" class="ui-progressbar ui-widget ui-widget-content ui-corner-all" style="position: relative;">'
                                + '<div id="' + uid + fileID + 'ProgressValue" class="ui-progressbar-value ui-widget-header ui-corner-left" style="position: absolute; left: 0px; top: 0px; width: 1px;"></div>'
                                + '<div id="' + uid + fileID + 'ProgressLabel" class="ui-progressbar-label" style="position: absolute; left: 0px; top: 0px; width: 100%; z-index: 99999;' + (opts.progressValueColor ? ' color: ' + opts.progressValueColor : '') + '"></div>'
                              + '</div>'
                            + '</div>'
                        );
                        $('#' + uid + fileID + ' .file').width(
                            $('#' + uid + fileID + ' .ui-upload-label').width() - $('#' + uid + fileID + ' .ui-icon').width() - 5
                        );
                    }
                });
            });
        },

        uiloadSetup : function(settingName, settingValue, resetObject) {
            var returnValue = false;
            $(this).each(function() {
                if (settingName == 'scriptData' && settingValue !== null) {
                    if (resetObject) {
                        var scriptData = settingValue;
                    } else {
                        var scriptData = $.extend(opts.scriptData, settingValue);
                    }
                    var scriptDataString = '';
                    for (var name in scriptData) {
                        scriptDataString += '&' + name + '=' + escape(scriptData[name]);
                    }
                    settingValue = scriptDataString.substr(1);
                }
                returnValue = document.getElementById($(this).attr('id') + swfSuffix).uploadParams(settingName, settingValue);
            });
            if (settingValue == null) {
                if (settingName == 'scriptData') {
                    var returnSplit = unescape(returnValue).split('&');
                    var returnObj   = new Object();
                    for (var i = 0; i < returnSplit.length; i++) {
                        var iSplit = returnSplit[i].split('=');
                        returnObj[iSplit[0]] = iSplit[1];
                    }
                    returnValue = returnObj;
                }
                return returnValue;
            }
        },

        uiloadFileTypes: function(types) {
            $(this).uiloadSetup('ftypes', _filetypes(types));
        },

        uiloadFileName: function(name) {
            $(this).uiloadSetup('rename', name);
        },

        uiloadToggle: function (disabled) {
            $(this).each(function() {
                var id = $(this).attr('id');
                var swfobj = '#' + id + swfSuffix;
                var btnobj = '#' + id + 'Browse'
                if (disabled) {
                    $(swfobj).css({ 'height' : '1px', 'width' : '1px' });
                } else {
                    $(swfobj).css({ 'height' : $(btnobj).outerHeight(), 'width' : $(btnobj).outerWidth() });
                }
            });
        },

        uiloadUpload: function(fileID) {
            $(this).each(function() {
                document.getElementById($(this).attr('id') + swfSuffix).loadFile(fileID, false);
            });
        },

        uiloadCancel: function(fileID) {
            $(this).each(function() {
                document.getElementById($(this).attr('id') + swfSuffix).cancelFile(fileID, true, false);
            });
        },

        uiloadClear: function() {
            $(this).each(function() {
                document.getElementById($(this).attr('id') + swfSuffix).clearQueue(true);
            });
        },

        uiloadDestroy: function() {
            $(this).each(function() {
                var uid = $(this).attr('id');
                $('#' + uid).css({ 'display':'', 'visibility':'' });
                $('#' + uid + 'Flash').empty();
                $('#' + uid + 'Body').remove();
                $(this).removeData();
            });
        }

    })

})(jQuery);


