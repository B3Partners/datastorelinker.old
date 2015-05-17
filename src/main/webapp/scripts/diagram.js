var maxNameLength = 25;
var columnSize = 25;
var rowSize = 12;
var multipleChildsOffset =3.2;
$(document).ready(function() {
    createStyles();
    for (var i = 0; i < processes.length; i++) {
        var process = processes[i];
        var fullName = process.name; 
        var $div = $("<div>", {id: "process" + process.id, class: "window", title: fullName});
        $div.html(shortenName(fullName));
        $("#main").append($div);
    }
    initPlumbing();
    
     $("#main div[title]").qtip({
            content: false,
            position: {
                corner: {
                    tooltip: "topLeft",
                    target: "bottomRight"
                }
            },
            style: {
                "font-size": 12,
                //width: "200px",
                width: {
                    max: 700
                },
                border: {
                    width: 2,
                    radius: 8
                },
                name: "cream",
                tip: true
            }
        });
});

function shortenName(name){
    if(name.length > maxNameLength){
        return name.substring(0, maxNameLength) + "...";
    }else{
        return name;
    }
}

function initPlumbing() {
    var color = "#19619B";

    var instance = jsPlumb.getInstance({
        // notice the 'curviness' argument to this Bezier curve.  the curves on this page are far smoother
        // than the curves on the first demo, which use the default curviness value.			
        Connector: ["Bezier", {curviness: 50}],
        DragOptions: {cursor: "pointer", zIndex: 2000},
        PaintStyle: {strokeStyle: color, lineWidth: 2},
        EndpointStyle: {radius: 1, fillStyle: color},
        HoverPaintStyle: {strokeStyle: "#19619B"},
        EndpointHoverStyle: {fillStyle: "#19619B"},
        Container: "main"
    });

    // suspend drawing and initialise.
    instance.doWhileSuspended(function() {
        // declare some common values:
        var arrowCommon = {foldback: 0.7, fillStyle: color, width: 24},
        // use three-arg spec to create two different arrows with the common values:
        overlays = [
            ["Arrow", {location: 1}, arrowCommon]
        ];

        // add endpoints, giving them a UUID.
        // you DO NOT NEED to use this method. You can use your library's selector method.
        // the jsPlumb demos use it so that the code can be shared between all three libraries.
        var windows = jsPlumb.getSelector(".chart-demo .window");
        for (var i = 0; i < windows.length; i++) {
            instance.addEndpoint(windows[i], {
                uuid: windows[i].getAttribute("id") + "-right",
                anchor: "Right",
                maxConnections: -1
            });
            instance.addEndpoint(windows[i], {
                uuid: windows[i].getAttribute("id") + "-left",
                anchor: "Left",
                maxConnections: -1
            });
        }

        for (var i = 0; i < processes.length; i++) {
            var process = processes[i];
            if (process.ancestor !== undefined) {
                instance.connect({uuids: ["process" + process.ancestor + "-right", "process" + process.id + "-left"], overlays: overlays});
            }
        }

        instance.draggable(windows);
    });
}

function createStyles() {
    var styles = "";
    var row = 0;

    var processRows = {};
    var rest = new Array();
    for (var i = 0; i < processes.length; i++) {
        var process = processes[i];
        if (process.ancestor === undefined) {
            processRows[process.id] = row;
            styles += createStyle(process.id, row, 0,0);
            row++;
        } else {
            rest.push(process);
        }
    }
    
    var multipleChilds = {};
    for (var i = 0; i < rest.length; i++) {
        var process = rest[i];
        if(multipleChilds[process.ancestor] === undefined){
            multipleChilds[process.ancestor] = -1;
        }
        
        multipleChilds[process.ancestor] = multipleChilds[process.ancestor] +1;
        var ancestor = getProcess(process.ancestor);
        var ancestorsAncestorChilds = multipleChilds[ancestor.ancestor];
        var row = getRow(process.ancestor,processRows );
        var offset = multipleChilds[process.ancestor] +( ancestorsAncestorChilds !== undefined?ancestorsAncestorChilds : 0);
        
        var style = createStyle(process.id, row, process.numAncestors,offset);
        styles += style;
    }

    $("<style type='text/css'>" + styles + "</style>").appendTo("head");
}

function getRow(id, processRows){
    var p = getProcess(id);
    
    while(p.ancestor !== undefined){
        p = getProcess(p.ancestor);
    }
    
    return processRows[p.id];
}

function getProcess(id){
    for(var i = 0 ; i< processes.length ;i++){
        var process = processes[i];
        if(process.id === id){
            return process;
        }
    }
}

function createStyle(id, row, column, numChilds) {
    var extraRowOffset = numChilds * multipleChildsOffset; // Extra calculation for ancestors with multiple children.
    var style = "#process" + id + " { left:" + (columnSize * column) + "em; top:" + ((rowSize * row) + extraRowOffset) + "em;}";
    return style;
}

