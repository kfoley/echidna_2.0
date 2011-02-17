/*
 * Echidna Import Wizard.
 * The import wizard is mostly a Javascript application, backed by a couple
 * of Ajax calls. It uses the jquery.history.js plugin to support back button
 * functionality.
 */
var wizard = {
    conditionsAndGroups: [],
    selectedConditions: []
};

// array filter method, predicate is a function that takes (elem, index)
wizard.filter = function(array, predicate) {
    var result = [];
    for (var i = 0; i < array.length; i++) {
        if (predicate(array[i], i)) result.push(array[i]);
    }
    return result;
};

// wizard navigation
wizard.displayStep = function(step) {
  $('#step1_3').hide();
  $('#step2_3').hide();
  $('#step3_3').hide();

  if (step == 1) $('#step1_3').show();
  else if (step == 2) $('#step2_3').show();
  else if (step == 3) $('#step3_3').show();
  $.history.load(step);
};

// generates HTML code for the table of imported conditions
wizard.makeConditionAndGroupsTable = function() {
    var result = '<table id="condition-list"><tbody>\n';
    for (var i = 0; i < wizard.conditionsAndGroups.length; i++) {
        var condition = wizard.conditionsAndGroups[i];
        result += '<tr><td class="cond"><input id="' + condition + '" type="checkbox">' + condition +
            '<br>Groups: - (TODO)</td></tr>';
    }
    result += '</tbody></table>';
    return result; 
};

// generates HTML code for the currently selected conditions for grouping
wizard.makeSelectedConditionsTable = function() {
    var result = '<table id="selected-conditions"><tbody>\n';
    for (var i = 0; i < wizard.selectedConditions.length; i++) {
        var condition = wizard.selectedConditions[i];
        result += '<tr><td>' + condition + '&nbsp;<a href="#2" id="delete-selected_' + i + '"><img src="images/delete_icon.gif"></a></td></tr>';
    }
    result += '</tbody></table>';
    return result; 
};

wizard.updateSelectedConditionsTable = function() {
    $(wizard.makeSelectedConditionsTable()).replaceAll('#selected-conditions');
    wizard.addDeleteLinkHandlers();
};

wizard.removeSelectedAt = function(removeIndex) {
    wizard.selectedConditions =  wizard.filter(wizard.selectedConditions,
                                               function (elem, index) { return index != removeIndex; });
    wizard.updateSelectedConditionsTable();
};

// Install handlers for the delete links in the list of selected conditions
wizard.addDeleteLinkHandlers = function() {
    // add link handlers
    for (var i = 0; i < wizard.selectedConditions.length; i++) {
        $('#delete-selected_' + i).click(function() {
            wizard.removeSelectedAt($(this).attr('id').split('_')[1]);
            return false;
        });
    }
};

wizard.addCheckedConditions = function() {
    var selected = $('td :checkbox:checked');
    selected.each(function(index, elem) {
        var id = elem.id;
        if ($.inArray(id, wizard.selectedConditions) == -1) {
            wizard.selectedConditions.push(id);
        }
    });
    selected.attr('checked', false);
    wizard.updateSelectedConditionsTable();
    return false;
};

wizard.reloadGroupSelectBox = function() {
    $.ajax({
        url: 'composites/allgroups',
        success: function(result) {
            $(result).replaceAll('#all-condition-groups');
        }
    });
};

// Application entry point
$(document).ready(function() {
    $.history.init(function(hash) {
        if (hash == "") {
            wizard.displayStep(1);
        } else {
            wizard.displayStep(hash);
        }
    }, { unescape: ",/" });

    $('#next_1_3').click(function() {
        $.ajax({
            url: 'import_wizard/conditions_and_groups?project_id=1064&timestamp=20100804_163517',
            dataType: 'json',
            success: function(result) {
                wizard.conditionsAndGroups = result;
                $(wizard.makeConditionAndGroupsTable()).replaceAll('#condition-list');
            }
        });
        wizard.displayStep(2);
    });

    $('#next_2_3').click(function() {
        wizard.displayStep(3);
    });

    $('#prev_2_3').click(function() { history.go(-1); });
    $('#prev_3_3').click(function() { history.go(-1); });

    $('#checkall').click(function() {
        $('td :checkbox').attr('checked', $('#checkall').attr('checked'));
    });

    $('#add-selected-conditions').click(wizard.addCheckedConditions);

    $('#new-group-dialog').dialog({title: 'Create Group',
                                   buttons: { 'Ok': function() { }, 'Cancel': function() { $(this).dialog('close'); } },
                                   modal: true
                                  });
    $('#new-group-dialog').dialog('close');
    $('#create-group').click(function() {
        $('#new-group-dialog').dialog('open');
    });
    
    wizard.reloadGroupSelectBox();
});
