/**
 * Dialoage einrichten
 */
(function($) {
    $.extend({
        /**
         * Alert dialog for jQuery UI.  Accepts the following options:
         * title - The title of the dialog
         * text - The text within the dialog
         * button - The text on the button
         * onclose - Callback for when the window is closed
         * cssclass - special class Name:
         *            alert, confirm, error, info, success, notice
         */
        alert: function(options) {
            if (!options) {
                var options = {};
            }
            // Define the buttons
            var buttons = {};
            buttons[(options.button) ? options.buttons : 'OK'] = function() {
                $('#alert-dialog').dialog('close');
			}
            // Create the dialog in the DOM
            if (options.cssclass) {
                $('body').append('<div id="alert-dialog"><div class="ui-dialog-special"><div class="ui-dialog-icon"><div class="ui-dialog-text">' + (options.text ? options.text : '&#160;') + '<\/div><\/div><\/div>');
            } else {
                $('body').append('<div id="alert-dialog">' + (options.text ? options.text : '&#160;') + '</div>');
            }
            // jQuery UI dialog call
            $('#alert-dialog').dialog({
                'dialogClass' : (options.cssclass ? options.cssclass : ''),
                'bgiframe'    : (($.blockUI && $.unblockUI) ? false : true),
                //'height'      : (options.height && parseInt(options.height) > 100) ? options.height : 100,
                'width'       : (options.width  && parseInt(options.width) > 300)  ? options.width  : 300,
                'title'       : (options.title)  ? options.title  : 'Alert',
                'buttons'     : buttons,
                'modal'       : true,
                'close'       : function() {
                    $('#alert-dialog').dialog('destroy');
                    $('#alert-dialog').remove();
                    if (typeof(options.onclose) == 'function') {
                        options.onclose();
                    }
                },
                'open' : function() {
                    if (typeof($.fn.button) !== 'undefined' && typeof($.fn.button) == 'function') {
                        $('.ui-dialog-buttonpane button:first').button({
                            label: (options.text_true) ? options.text_true : (window.I18N && I18N.ok) ? I18N.ok : 'Ok'
                        });
                    }
                }
            });
        },

        /**
         * Confirm dialog for jQuery UI.  Accepts the following options:
         * title - The title of the dialog
         * text - The text within the dialog
         * text_true - Text for the true button
         * text_false - Text for the false button
         * ontrue - callback for true response
         * onfalse - callback for false response.
         * onclose - callback for dialog close.
         * cssclass - special class Name:
         *            alert, confirm, error, info, success, notice
         */
        confirm: function(options) {
            if (!options) {
                var options = {};
            }
            // Define the buttons
            var buttons = {};
            buttons[(options.text_false) ? options.text_false : 'No'] = function() {
                $('#confirm-dialog').dialog('close');
                if (typeof(options.onfalse) == 'function') {
                    options.onfalse();
                }
			};
            buttons[(options.text_true) ? options.text_true : 'Yes'] = function() {
                $('#confirm-dialog').dialog('close');
                if (typeof(options.ontrue) == 'function') {
                    options.ontrue();
                }
			}
            // Create the dialog in the DOM
            if (options.cssclass) {
                $('body').append('<div id="confirm-dialog"><div class="ui-dialog-special"><div class="ui-dialog-icon"><div class="ui-dialog-text">' + (options.text ? options.text : '&#160;') + '<\/div><\/div><\/div>');
            } else {
                $('body').append('<div id="confirm-dialog">' + (options.text ? options.text : 'Are you sure?') + '</div>');
            }
            // jQuery UI dialog call
            $('#confirm-dialog').dialog({
                'dialogClass' : (options.cssclass ? options.cssclass : ''),
                'bgiframe'    : (($.blockUI && $.unblockUI) ? false : true),
                //'height'      : (options.height && parseInt(options.height) > 100) ? options.height : 100,
                'width'       : (options.width  && parseInt(options.width) > 300)  ? options.width  : 300,
                'title'       : (options.title)  ? options.title  : 'Confirm',
                'modal'       : true,
                'buttons'     : buttons,
                'open' : function() {
                    if (typeof($.fn.button) !== 'undefined' && typeof($.fn.button) == 'function') {
                        $('.ui-dialog-buttonpane button:first').button({
                            icons: {
                                'primary': 'ui-icon-circle-close'
                            },
                            label: (options.text_true) ? options.text_true : (window.I18N && I18N.no) ? I18N.no : 'No'
                        }).next().button({
                            icons: {
                                primary: 'ui-icon-circle-check'
                            },
                            label: (options.text_true) ? options.text_true : (window.I18N && I18N.yes) ? I18N.yes : 'Yes'
                        });
                    }
                },
                close : function() {
                    $('#confirm-dialog').dialog('destroy');
                    $('#confirm-dialog').remove();
                }
            });
		}

    });

        /**
         * -------------------------------------------------------------------
         * UPLOADER
         * -------------------------------------------------------------------
         */

        /*
        // Uploader einrichten
        var uploadopts = {
            // Auto-Upload
            auto: false,
            // Display Icons in Buttons
            btnIcon: false,
            // Start Button und Funktion
            btnStart: true, btnStartClick: true,
            // Cancel (Stop) Button und Funktion
            btnStop: true, btnStopClick: true,
            // Set to "always" to allow script access across domains
            swfaccess: 'sameDomain',
            // Pfad zum UI-Uploader
            swfuploader: 'swf/jquery-ui-upload.swf',
            // Methode, wie die Dateien uebertragen werden sollen.
            // Hinweis: POST ist die beste Variante
            method: 'POST',
            // Maximale Anzahl an Dateien in der Warteschlange
            maxfiles: 1,
            multi: false,
            // Maximale Groesse eine Datei (in Bytes)
            maxfilesize : 104857600,
            // Name des Upload-Datenobjekts zum ermitteln der Daten im Backend
            // Script.
            fdata : 'filedata',
            // Pfad zum Backend-Script
            script : ajaxurl,
            // Daten fuer das Backend-Script
            scriptData : {
                'ajax'   : 'yes',
                'site'   : 'media-files',
                'submit' : 'upload'
            },
            // Pfad zum Backend-Script fuer die Pruefung ob Datei existiert
            checkScript : ajaxurl,
            // Daten fuer das Backend-Script fuer Pruefung ob Datei existiert
            checkScriptData : {
                'ajax'   : 'yes',
                'site'   : 'media-files',
                'submit' : 'check'
            },
            // Pfad, in dem die hochgeladen Dateien gespeichert werden sollen.
            // Hinweis: In dieser Anwendung wird diese Angabe ignoriert, muss
            //          aber trotzdem auf '' gesetzt werden
            fpath: '',

            // Name der Datei, wie die Datei auf dem Server benannt und in
            // der Datenbank eingetragen werden soll. Dieser Wert durch das
            // Input-Feld 'title' gesetzt
            rename: null,

            // Erlaubte Dateitypen. Diese Werte werden durch das Input-Feld
            // 'file_type' ueberschrieben
            ftypes : {
                //'JPEG Image' : ['jpg', 'jpe', 'jpeg'],
                //'PNG Image' : 'png',
                //'GIF Image' : 'gif'
            },
            // Function to run when a file is selected
            onSelect : function() {},
            // Function to run when the queue reaches capacity
            onMaxFiles : function() {},
            // Function to run when script checks for duplicate files on the server
            onCheck : function() {},
            // Function to run when an item is cleared from the queue
            onCancel : function() {},
            onClear : function() {},
            // Function if an error occures
            onError    : function() {},
            // Function to run each time the upload progress is updated
            onProgress : function() {},
            // Function to run when an upload is completed
            onComplete : function() {},
            // Function to run when all uploads are completed
            onFinished : function() { }
        };

        // EXAMPLE
        function disableUploader(disabled) {
            $(uiload.id).uiloadToggle(disabled);
            if (!disabled) {
                $(uiload.id + 'Start,' + uiload.id + 'Stop,' + uiload.id + 'Browse').removeClass('ui-state-disabled').addClass('ui-state-default').hover(
                    function() { $(this).removeClass('ui-state-default').addClass('ui-state-hover'); },
                    function() { $(this).removeClass('ui-state-hover').addClass('ui-state-default'); }
                ).blur(function() { $(this).removeClass('ui-state-focus').removeClass('ui-state-hover').addClass('ui-state-default'); }).focus(function() { $(this).removeClass('ui-state-default').removeClass('ui-state-hover').addClass('ui-state-focus'); });

                $(uiload.id + 'Start').bind('click', function() { $(uiload.id).parents('form').trigger('submit'); return false; });
                $(uiload.id + 'Stop').bind('click', function() {
                    $(uiload.idtype).val('');
                    $(uiload.idtitle).val('');
                    $(uiload.id).uiloadClear();
                    setTimeout(function() {
                        disableUploader(true);
                    }, 10);
                    return false;
                });
                $(uiload.id).uiloadFileTypes(uiload.filetypes);
                $(uiload.id).uiloadSetup('fclass', uiload.fileclass);
            } else {
                $(uiload.id + 'Start,' + uiload.id + 'Stop,' + uiload.id + 'Browse').removeClass('ui-state-default').addClass('ui-state-disabled').hover(function() {
                    $(this).removeClass('ui-state-hover');
                }).focus(function() {
                    $(this).removeClass('ui-state-focus').removeClass('ui-state-hover');
                }).unbind('click').bind('click', function () { return false; });
            }
        }

        // Uploader initialisieren
        function initUploader(disabled) {
            uploadopts.scriptData[ajaxsid] = $.cookies.get(ajaxsid);
            $(uiload.id).uiload(uploadopts);
            disableUploader(disabled);
        }
        initUploader(false);
        */


})(jQuery);

