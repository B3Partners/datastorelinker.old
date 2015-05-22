// jQuery File Tree Plugin
//
// Version 1.01.0-aza1
//
// Cory S.N. LaViska
// A Beautiful Site (http://abeautifulsite.net/)
// 24 March 2008
//
// Modified by Carl Fürstenberg
//
// Visit http://abeautifulsite.net/notebook.php?article=58 for more information
//
// Usage: $('.fileTreeDemo').fileTree( options, callback )
//
// Options:  root           - root folder to display; default = /
//           fakeTopRoot    - show an fake top root, for situations where you won't have a direct single root in database
//           fakeTopRootText - text to show as the fake root, default is a single dot
//           script         - location of the serverside AJAX file to use; default = jqueryFileTree.php
//           folderEvent    - event to trigger expand/collapse; default = click
//           expandSpeed    - default = 500 (ms); use -1 for no animation
//           collapseSpeed  - default = 500 (ms); use -1 for no animation
//           expandEasing   - easing function to use on expand (optional)
//           collapseEasing - easing function to use on collapse (optional)
//           multiFolder    - whether or not to limit the browser to one subfolder at a time
//           loadMessage    - Message to display while initial tree loads (can be HTML)
//           fileCallback   - Callback when a file is choosen
//           dirExpandCallback - callback when a directory is expanded
//           dirCollapseCallback - callback when a directory is collapsed, return of false avoids collapsing
//           moveCallback   - callback when entity is moved
//           readyCallback  - callback to be fired after initial setup after initial ajax call
//           spinnerImage   - image to be used as spinner, should be an horizontal image with subimages laied out
//           spinnerWidth   - width of separate spinners
//           spinnerHeight  - height of separate spinners
//           spinnerSpeed   - speed of spinner
//           dragAndDrop    - enable drag and frop functionallity, requires jquery.event.drag.js and jquery.event.drop.js
//           extraAjaxOptions - extra (overriding) ajax options to use when getting files from the server
//
//
// History:
//
// 1.01-0aza1 - added callbacks, dragndrop, fakeroot and updated spinner, fix i18n probs + some more stuff
// 1.01 - updated to work with foreign characters in directory/file names (12 April 2008)
// 1.00 - released (24 March 2008)
//
// TERMS OF USE
// 
// jQuery File Tree is licensed under a Creative Commons License and is copyrighted (C)2008 by Cory S.N. LaViska.
// For details, visit http://creativecommons.org/licenses/by/3.0/us/
//
//if(jQuery)
(function($) {
    $.fn.fileTree = function(o) {
        // Defaults
        if( !o ) o = {};
        if( o.root == undefined ) o.root = '/';
        if( o.fakeTopRoot == undefined ) o.fakeTopRoot = false;
        if( o.fakeTopRootText == undefined ) o.fakeTopRootText = '.';
        if( o.script == undefined ) o.script = 'jqueryFileTree.php';
        if( o.scriptEvent == undefined ) o.scriptEvent = null;
        if( o.folderEvent == undefined ) o.folderEvent = 'click';
        if( o.expandSpeed == undefined ) o.expandSpeed= 500;
        if( o.hoverTimeout == undefined ) o.hoverTimeout= 500;
        if( o.collapseSpeed == undefined ) o.collapseSpeed= 500;
        if( o.expandEasing == undefined ) o.expandEasing = null;
        if( o.collapseEasing == undefined ) o.collapseEasing = null;
        if( o.multiFolder == undefined ) o.multiFolder = true;
        if( o.loadMessage == undefined ) o.loadMessage = 'Loading...';
        if( o.fileCallback == undefined ) o.fileCallback = function(file) {  };
        if( o.dirExpandCallback == undefined ) o.dirExpandCallback = function(dir) {  };
        if( o.dirCollapseCallback == undefined ) o.dirCollapseCallback = function(dir) {return true;};
        if( o.moveCallback == undefined ) o.moveCallback = function(from, to, directory) {  };
        if( o.readyCallback == undefined ) o.readyCallback = function() {  };
        if( o.spinnerImage == undefined ) o.spinnerImage = false;//'images/spinner.gif' ;
        if( o.spinnerWidth == undefined ) o.spinnerWidth = 16;
        if( o.spinnerHeight == undefined ) o.spinnerHeight = 16;
        if( o.spinnerSpeed == undefined ) o.spinnerSpeed = 25;
        if( o.dragAndDrop == undefined ) o.dragAndDrop = true;
        if( o.extraAjaxOptions == undefined ) o.extraAjaxOptions = {};
        if( o.activeClass == undefined ) o.activeClass = "";
        if( o.activateDirsOnClick == undefined ) o.activateDirsOnClick = true;
        if( o.activateFilesOnClick == undefined ) o.activateFilesOnClick = true;
        if( o.expandOnFirstCallTo == undefined ) o.expandOnFirstCallTo = null;

        $(this).each( function() {
            // used in bindTree to keep track of old selection.
            // We must keep track of this globally per filetree root to be able to switch file selections between directories.
            var oldrel = "";
            var spinner = $();

            // For a fake root, we use an simple div
            if( o.fakeTopRoot ) {
                $(this).empty();
                $(this).append(
                    $('<div />').addClass("jqueryFileTreeFakeRoot").append(
                        o.fakeTopRootText
                        )
                    ).append(
                    $('<div />').addClass("jqueryFileTreeRealRoot").append(
                        $('<ul />').addClass("jqueryFileTree start").append(
                            $('<li />').addClass("wait").append(o.loadMessage)
                            )
                        )
                    );

                if( o.dragAndDrop ) {
                    var fakeroot = $(this).find('.jqueryFileTreeFakeRoot');
                    fakeroot.bind( "dropstart", function( event ){
                        if( $(event.dragTarget).parent().parent().hasClass('jqueryFileTreeRealRoot') ) {
                            return false;
                        }

                        // activate the "drop" target element
                        $( this ).addClass("active");
                        $.dropManage();
                    });
                    fakeroot.bind( "drop", function( event ){


                        o.moveCallback($(event.dragTarget).children('a:first').attr('rel'), null, $(event.dragTarget).hasClass('directory') ? true : false );
                        // if there was a drop, move some data...
                        $( this ).parent().children('.jqueryFileTreeRealRoot').children('ul.jqueryFileTree').append( event.dragTarget );
                    // output details of the action...
                    });
                    fakeroot.bind( "dropend", function( event ){
                        // deactivate the "drop" target element
                        $( this ).removeClass("active");
                    });
                }
                // Get the initial file list
                showTree( $(this).children(".jqueryFileTreeRealRoot"), o.root );
            } else {
                $(this).empty();
                $(this).append(
                    $('<ul />').addClass("jqueryFileTree start").append(
                        $('<li />').addClass("wait").append(o.loadMessage)
                        )
                    );
                showTree( $(this), o.root );
            }

            function showTree(c, t, n) {
                $(c).addClass('wait');

                $(c).bind('rebindtree', function() {
                    bindTree(c);
                });

                var data = {};
                if (!!t)
                    data.dir = t;
                if (o.scriptEvent)
                    data[o.scriptEvent] = "t";
                if (o.expandOnFirstCallTo) {
                    data.expandTo = o.expandOnFirstCallTo;
                    o.expandOnFirstCallTo = null;
                }
                
                var error = function(xhr, textStatus, errorThrown) {
                        $(c).removeClass('wait');
                        window.console && console.log && console.log(textStatus + "\n\n" + errorThrown);
                };
                var success = function(data, textStatus, xhr) {
                        $(c).find('.start').html('');
                        var root = $(c).removeClass('wait');
                        spinner.remove();
                        root.append(data);
                        if( o.root == t ) {
                            $(c).find('UL:hidden').show();
                        } else {
                            $(c).find('UL:hidden').slideDown({
                                duration: o.expandSpeed,
                                easing: o.expandEasing
                            });
                        }
                        bindTree(c);
                        if( n ) n(c);
                        o.readyCallback(root);
                };
                
                if(o.noAjax) {
                    o.noAjax(data, success, function() { $(c).removeClass("wait") } );
                } else {
                    $(".jqueryFileTree.start").remove();
                    $.ajax($.extend(true, {
                        url: o.script,
                        type: 'POST',
                        data: data,
                        timeout: 30000,
                        error: error,
                        success: success
                    }, o.extraAjaxOptions));
                }
            }

            function bindTree(t) {
                $(t).find('LI A').bind(o.folderEvent, function(event) {
                    if( $(this).parent().hasClass('directory') ) {
                        if( $(this).parent().hasClass('collapsed') ) {
                            // Expand

                            if( !o.multiFolder ) {
                                $(this).parent().parent().find('UL').slideUp({
                                    duration: o.collapseSpeed,
                                    easing: o.collapseEasing
                                });
                                $(this).parent().parent().find('LI.directory').removeClass('expanded').addClass('collapsed');
                            }
                            $(this).parent().find('UL').remove(); // cleanup
                            showTree( $(this).parent(), $(this).attr('rel') );
                            $(this).parent().removeClass('collapsed').addClass('expanded');
                            if( oldrel != $(this).attr('rel') ) {
                                o.dirExpandCallback($(this).attr('rel'));
                            }
                        } else {
                            if( ! o.dirCollapseCallback($(this).attr('rel')) ) {
                                //event.preventDefault();//return false;
                                return;
                            }
                            // Collapse
                            // uncheck all input elements that are siblings of the anchor
                            // does not work for some reason.
                            //$(this).siblings("input").log("siblings input").attr("checked", false);
                            $(this).parent().find('UL').slideUp({
                                duration: o.collapseSpeed,
                                easing: o.collapseEasing,
                                complete: function() {
                                    // rigorous cleanup:
                                    $(this).parent().find('UL').remove();
                                }
                            });
                            $(this).parent().removeClass('expanded').addClass('collapsed');
                        }

                        if (o.activateDirsOnClick) {
                            $(this).parents(".jqueryFileTree").last().find("li a").removeClass(o.activeClass);
                            $(this).addClass(o.activeClass);
                            $(this).siblings("input:radio").attr("checked", true);
                        }
                    } else if( oldrel != $(this).attr('rel') ) {
                        o.fileCallback($(this).attr('rel'), this);
                        if (o.activateFilesOnClick) {
                            $(this).parents(".jqueryFileTree").last().find("li a").removeClass(o.activeClass);
                            $(this).addClass(o.activeClass);
                            $(this).siblings("input:radio").attr("checked", true);
                        }
                    }
                    oldrel = $(this).attr('rel');
                    //event.preventDefault();//return false;
                    return;
                });
                if( o.dragAndDrop ) {
                    var all = $(t).find('LI');
                    all.bind( "dragstart",
                        function( event ){
                            if( ! $(event.target).is('a') ) {
                                return false;
                            }
                            $.dropManage();
                            // ref the "dragged" element, make a copy
                            var $drag = $( this ), $proxy = $drag.clone();
                            // modify the "dragged" source element
                            $drag.addClass("outline");
                            // insert and return the "proxy" element
                            return $proxy.appendTo( document.body ).addClass("ghost");
                        });
                    all.bind( "drag", function( event ){
                        // update the "proxy" element position
                        $( event.dragProxy ).css({
                            left: event.offsetX,
                            top: event.offsetY
                        });
                    });
                    all.bind( "dragend", function( event ){
                        // remove the "proxy" element
                        $( event.dragProxy ).fadeOut( "normal", function(){
                            $( this ).remove();
                        });
                        // if there is no drop AND the target was previously dropped
                        if ( !event.dropTarget && $(this).parent().is(".drop") ){
                        }
                        // restore to a normal state
                        $( this ).removeClass("outline");

                    });

                    var dirs = $(t).find('LI.directory > A');

                    dirs.bind( "dropstart", function( event ){

                        // don't drop in itself or children of self
                        if($(event.dragTarget).hasClass('directory') &&
                            $(this).parents('li.directory').filter(
                                function(){
                                    return $(this).children('a').attr('rel') == $(event.dragTarget).children('a').attr('rel')
                                }
                                ).length > 0 ) {
                            return false;
                        }
                        if( $(this).parent().hasClass('collapsed') ) {
                            $(this).oneTime( o.hoverTimeout, 'expand', function() {
                                // Expand
                                if( !o.multiFolder ) {
                                    $(this).parent().parent().find('UL').slideUp({
                                        duration: o.collapseSpeed,
                                        easing: o.collapseEasing
                                        });
                                    $(this).parent().parent().find('LI.directory').removeClass('expanded').addClass('collapsed');
                                }
                                $(this).parent().find('UL').remove(); // cleanup
                                showTree( $(this).parent(), $(this).attr('rel') );
                                $(this).parent().removeClass('collapsed').addClass('expanded');
                            });
                        }

                        // activate the "drop" target element
                        $( this ).parent().addClass("active");
                        $.dropManage();
                        return true;
                    });
                    dirs.bind( "drop", function( event ){


                        o.moveCallback($(event.dragTarget).children('a:first').attr('rel'),  $(this).attr('rel'), $(event.dragTarget).hasClass('directory') ? true : false );
                        if( $(this).parent().hasClass('collapsed') ) {
                            // Expand
                            if( !o.multiFolder ) {
                                $(this).parent().parent().find('UL').slideUp({
                                    duration: o.collapseSpeed,
                                    easing: o.collapseEasing
                                    });
                                $(this).parent().parent().find('LI.directory').removeClass('expanded').addClass('collapsed');
                            }
                            $(this).parent().find('UL').remove(); // cleanup
                            showTree( $(this).parent(), $(this).attr('rel'), function(target) {

                                $( target ).children('ul:first').append( event.dragTarget );
                            });
                            $(this).parent().removeClass('collapsed').addClass('expanded');
                        } else {
                            // if there was a drop, move some data...
                            $( this ).parent().children('ul:first').append( event.dragTarget );
                        }
                    // output details of the action...
                    });
                    dirs.bind( "dropend", function( event ){
                        $(this).stopTime('expand');
                        // deactivate the "drop" target element
                        $( this ).parent().removeClass("active");
                    });
                }
                // Prevent A from triggering the # on non-click events
                if( o.folderEvent.toLowerCase != 'click' ) $(t).find('LI A').bind('click', function() {return false;});
            }
        });
    }
})(jQuery);
