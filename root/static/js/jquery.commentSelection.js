locations = {
    one     : {
        id              : 'one',
        url             : '/IHE/1/',
        start_path      : '/div/p:[1]',
        start_offset    : 31,
        end_path        : '/div/p:[1]',
        end_offset      : 68,
        child_paths     : [],
    },
    two     : {
        id              : 'two',
        url             : '/IHE/1/',
        start_path      : '/div/p:[1]',
        start_offset    : 62,
        end_path        : '/div/p:[1]',
        end_offset      : 119,
        child_paths     : [],
    },
    tre     : {
        id              : 'tre',
        url             : '/IHE/1/',
        start_path      : '/div/p[2]:[1]',
        start_offset    : 278,
        end_path        : '/div/p[2]:[1]',
        end_offset      : 292,
        child_paths     : [],
    },
};
comments = [
    {
        id          : 'one',
        location    : locations.one,
        in_reply_to : null,
        subject     : 'This is racist',
        comment     : 'expand that thinking!'
    },
    {
        id          : 'two',
        location    : locations.two,
        in_reply_to : null,
        subject     : 'This is wrong',
        comment     : 'What lessons?'
    },
    {
        id          : 'three',
        location    : locations.tre,
        in_reply_to : null,
        subject     : 'This is making an assumption',
        comment     : 'Not me!'
    },
];
classes = {
    '^1$'           : 'single_comment',
    '^[2-4]$'       : 'few_comments',
    '^[5-9]$'       : 'some_comments',
    '^[1-2][0-9]$'  : 'many_comments',
    '^[3-4][0-9]$'  : 'excessive_comments',
    '^([5-9][0-9])|([0-9]{3,})$' : 'hot_topic'
};

$(document).ready(function(){
    $('#text_content').generateCommentClone();

    // bind Mouseup
    $('#text_content').bind("mouseup", function(){
        var range = $('#text_content').getRangeAt();
        // Check if its a click
        if (range.startContainer == range.endContainer && range.startOffset == range.endOffset) {
            $('div#comment_form').hide();
            displayComments(range);
            return;
        }
        // otherwise its a selection
        $('div#comment_form').show().children('form').unbind('submit').submit(function() {
            var location = createLocation(range);
            var comment = createComment(location,this.comment.value);
            $('div#comment_form').hide();
            this.reset();
            $('#text_content').generateCommentClone();
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
    var prepath = $('#text_content').getXPath();
    xpath = xpath.replace(prepath,'');
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
                                    var classes = getClasses(comments);
                                    newHTML += '<span class="'+classes+'">'+cha+'</span>';
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

function getClasses(comments) {
    var relevant_classes = [];
    $.each(comments,
        function(index,comment) {
            relevant_classes.push(comment.id);
        }
    );
    var count = comments.length+'';
    $.each(classes,
        function(exp,class) {
            var regex = new RegExp(exp);
            if(count.match(regex)) {
                relevant_classes.push(class);
            }
        }
    );
    return relevant_classes.join(' ');
}

// This should be extended to handle ranges with different start and ends
function getComments(cords) {
    var foundComments = [];
    $.each(comments,
        function(index,comment) {
            var location = comment.location;
            if(cords.startPath == location.start_path) {
                if(cords.startOffset > location.start_offset) {
                    if(cords.endPath != location.end_path || cords.endOffset < location.end_offset) {
                        foundComments.push(comment);
                    }
                }
            }
            else if(cords.endPath == location.end_path) {
                if(cords.endOffset < location.end_offset) {
                    foundComments.push(comment);
                }
            }
            else if(location.child_paths.length) {
                $.each(location.child_paths,
                    function(index,path) {
                        if(cords.startPath == path || cords.endPath == path) {
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
    $('.selected').removeClass('selected');
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
            var class = comment.id;
            $('.'+class).addClass('selected');
            alert(comment.comment);
        }
    );
}
function createLocation(range) {
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
    var location = {
        id              : new Date().getTime(),
        url             : '/IHE/1/',
        start_path      : $(range.startContainer).getPath(),
        start_offset    : range.startOffset,
        end_path        : $(range.endContainer).getPath(),
        end_offset      : range.endOffset+1,
        child_paths     : nodes,
    };
    locations[location.id] = location;
    return location;
}
function createComment(location,commentText) {
    var comment = {
        id          : new Date().getTime(),
        location    : location,
        comment     : commentText,
    };
    comments.push(comment);
}

// getLocation/getRange should be jquery functions
// $(#text_content).getLocation(range)
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

