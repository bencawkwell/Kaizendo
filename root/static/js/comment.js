comments = [
    {
        startPath   : '/html/body/div/p:[1]',
        startOffset : 48,
        endPath     : '/html/body/div/p:[1]',
        endOffset   : 84,
        childPaths  : [],
        comment     : 'expand that thinking!'
    },
    {
        startPath   : '/html/body/div/p:[1]',
        startOffset : 74,
        endPath     : '/html/body/div/p:[1]',
        endOffset   : 136,
        childPaths  : [],
        comment     : 'What lessons?'
    },
    {
        startPath   : '/html/body/div/p[2]:[1]',
        startOffset : 295,
        endPath     : '/html/body/div/p[2]:[1]',
        endOffset   : 309,
        childPaths  : [],
        comment     : 'Not me!'
    },
    {
        startPath   : '/html/body/div/p:[1]',
        startOffset : 550,
        endPath     : '/html/body/div/p:[2]',
        endOffset   : 16,
        childPaths  : ['/html/body/div/p/b:[1]'],
        comment     : 'Fool!'
    }
];

$(document).ready(function(){
    $('#container').generateCommentClone();

    // bind Mouseup
    $('#container').bind("mouseup", function(){
        var range = $('#container').getRangeAt();
        // Check if its a click
        if (range.startContainer == range.endContainer && range.startOffset == range.endOffset) {
            $('form.add_comment').hide();
            displayComments(range);
            return;
        }
        // otherwise its a selection
        $('form.add_comment').show().unbind('submit').submit(function() {
            var comment = createComment(range,this.comment.value);
            $('form.add_comment').hide();
            this.reset();
            $('#container').generateCommentClone();
            return false;
        });
    });
});

$.fn.getPath = function() {
    var xpath;
    if(this[0].nodeType == 3) {
        xpath = this.parent().getXPath()[0];
    }
    else {
        xpath = this.getXPath()[0];
    }
    return xpath+':['+this.nodeIndex()+']';
}

jQuery.fn.nodeIndex = function() {
    return $(this).prevAll().length + 1;
};

jQuery.fn.generateCommentClone = function() {
    var cloneHTML = $(this).generateCommentHTML();
    $(this).next('.clone').remove();
    $(this).after('<div class="clone">'+cloneHTML+'</div>');
};

$.fn.generateCommentHTML = function() {
    var newHTML = '';
    this.each(
        function() {
            var childNodes = this.childNodes;
            $(childNodes).each(
                function(index,element) {
                    if(this.nodeType == 3)
                    {
                        var path = $(this).getPath();
                        $.each(this.nodeValue,
                            function(index,cha) {
                                var cords = {
                                    startPath   : path,
                                    startOffset : index+1,
                                    endPath     : path,
                                    endOffset   : index+1,
                                };
                                var comments = getComments(cords);
                                if(comments.length)
                                {
                                    newHTML += '<span class="highlight'+comments.length+'">'+cha+'</span>';
                                }
                                else {
                                    newHTML += cha;
                                }
                            }
                        );
                    }
                    else {
                        //alert($(element).generateCommentHTML());
                        newHTML += '<'+this.tagName+'>'+$(this).generateCommentHTML()+'</'+this.tagName+'>';
                    }
                }
            );
        }
    );
    return newHTML;
}

// This should be extended to handle ranges with different start and ends
function getComments(cords) {
    var foundComments = [];
    $.each(comments,
        function(index,comment) {
            if(cords.startPath == comment.startPath) {
                if(cords.startOffset > comment.startOffset) {
                    if(cords.endPath != comment.endPath || cords.endOffset < comment.endOffset) {
                        foundComments.push(comment);
                    }
                }
            }
            else if(cords.endPath == comment.endPath) {
                if(cords.endOffset < comment.endOffset) {
                    foundComments.push(comment);
                }
            }
            else if(comment.childPaths.length) {
                $.each(comment.childPaths,
                    function(index,childPath) {
                        if(cords.startPath == childPath || cords.endPath == childPath) {
                            foundComments.push(comment);
                            return;
                        }
                    }
                );
            }
        }
    );
    return foundComments;
}

// This should be extended to handle ranges with different start and ends
function displayComments(range) {
    var path = $(range.startContainer).getPath();
    var cords = {
        startPath   : path,
        startOffset : range.startOffset,
        endPath     : path,
        endOffset   : range.endOffset,
    };
    var foundComments = getComments(cords);
    $.each(foundComments,
        function(index,comment) {
            alert(comment.comment);
        }
    );
}

function createComment(range,commentText) {
    var nodes = [];
    var allNodes = range.GetContainedNodes()[0];
    if(allNodes.length > 2)
    {
        allNodes.shift();
        allNodes.pop();
        $.each(allNodes,
            function(index,node) {
                nodes.push($(node).getPath());
            }
        );
    }
    var comment = {
        startPath   : $(range.startContainer).getPath(),
        startOffset : range.startOffset,
        endPath     : $(range.endContainer).getPath(),
        endOffset   : range.endOffset+1,
        childPaths  : nodes,
        comment     : commentText,
    };
    comments.push(comment);
}

// getLocation/getRange should be jquery functions
// $(#container).getLocation(range)
function getLocation(range) {
    var start_xpath = $(range.startContainer).parent().getXPath();
    var end_xpath = $(range.endContainer).parent().getXPath();
    // remember to make path relative to the container
    //start_xpath.replace('','');
    //end_xpath.replace('','');
    return start_xpath[0]+':'+range.startOffset+':'+end_xpath[0]+':'+range.endOffset;
}

// Needs to be based on the updated DOM?
// or get
function getRange(location) {
    var parts = location.split(':');
    var start_xpath = parts[0];
    var start_offset = parts[1];
    var end_xpath = parts[2];
    var end_offset = parts[3];
}

function highlightRange(range) {
}

// each time a span is added to the text, we need to increase the offset
// by the amount added (span with classes for highlighting)
function calculateOffset() {
    var difference = content.length - existing_length;
    offset += difference;
}

