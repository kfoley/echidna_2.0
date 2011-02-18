/*
 * Echidna Import Wizard.
 * The import wizard is mostly a Javascript application, backed by a couple
 * of Ajax calls. It uses the jquery.history.js plugin to support back button
 * functionality.
 * The main idea is that the wizard object holds all input information until
 * the user hits the final commit. The conversational state is serialized into
 * JSON and submitted to the backend.
 */
var wizard = {
    // a hash table which has conditions as key and an array of group names
    // as value
    conditionsAndGroups: { },

    // an array of strings containing all condition groups
    allConditionGroups: [],

    // holds the current SBEAMS project id
    // holds the current SBEAMS timestamp
    sbeamsProjectId: '',
    sbeamsTimestamp: '',

    // holds the currently selected condition names contained in the
    // group assign step
    selectedConditions: [],
    
    // a row in metadata holds entries of
    // { 'key': <somekey>, 'type': <observation|perturbation>, <condition 1>: [<value>, <unit>], ... }
    metadata: [],

    // loaded at page load time, we generate select boxes out of them
    metadataTypes: [],
    units: []
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

// *****************************
// *** Step 2 functions
// *********************
// computes a string representing a list of groups associated with a condition
wizard.makeGroupString = function(condition) {
    var groups = wizard.conditionsAndGroups[condition];
    if (groups.length == 0) return '-';
    var result = '';
    for (var i = 0; i < groups.length; i++) {
        if (i > 0) result += ', ';
        result += groups[i];
    }
    return result;
};

// generates HTML code for the table of imported conditions
wizard.makeConditionAndGroupsTable = function() {
    var result = '<table id="condition-list"><tbody>\n';
    for (var condition in wizard.conditionsAndGroups) {
        result += '<tr><td class="cond"><input id="' + condition + '" type="checkbox">' + condition +
            '<br>Groups: ' + wizard.makeGroupString(condition) + '</td></tr>';
    }
    result += '</tbody></table>';
    return result; 
};
wizard.updateConditionAndGroupsTable = function() {
    $(wizard.makeConditionAndGroupsTable()).replaceAll('#condition-list');
};

// generates HTML code for the currently selected conditions for grouping
wizard.makeSelectedConditionsTable = function() {
    var result = '<table id="selected-conditions"><tbody>\n';
    for (var i = 0; i < wizard.selectedConditions.length; i++) {
        var condition = wizard.selectedConditions[i];
        result += '<tr><td>' + condition + '&nbsp;<a href="#2" id="delete-selected_' + i + '"><img src="images/delete_icon.png"></a></td></tr>';
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

wizard.applyGrouping = function() {
    var selectedGroup = $('#all-condition-groups option:selected').val();
    console.debug('applyGroup: ' + selectedGroup);
    wizard.addGroupToSelections(selectedGroup);
};

wizard.addGroupToSelections = function(groupName) {
    for (var i = 0; i < wizard.selectedConditions.length; i++) {
        var cond = wizard.selectedConditions[i];
        var groups = wizard.conditionsAndGroups[cond];
        groups.push(groupName);
    }
    // clear selected box
    wizard.selectedConditions = [];
    wizard.updateSelectedConditionsTable();
    wizard.updateConditionAndGroupsTable();
};

wizard.createAndAddGroup = function(groupName) {
    wizard.allConditionGroups.push(groupName);
    wizard.updateGroupSelectBox();
    wizard.addGroupToSelections(groupName);
};

wizard.updateGroupSelectBox = function() {
    var result = '<select id="all-condition-groups">';
    for (var i = 0; i < wizard.allConditionGroups.length; i++) {
        var group = wizard.allConditionGroups[i];
        result += '<option value="' + group + '">' + group + '</option>';
    }
    $(result).replaceAll('#all-condition-groups');
};

wizard.reloadGroupSelectBox = function() {
    $.ajax({
        url: 'composites/allgroups',
        dataType: 'json',
        success: function(result) {
            wizard.allConditionGroups = result;
            wizard.updateGroupSelectBox();
        }
    });
};

// *****************************
// *** Step 3 functions
// *********************
wizard.addMetadataRow = function() {
    $('#metadata-table tr:last').after(wizard.makeMetadataRowForEdit());
    console.debug('addMetadataRow()');
};

wizard.makeMetadataSelectBox = function() {
    return '<select><option>Knockout</option></select>';
};

// generates a metadata row from the conditions we have
wizard.makeMetadataRowForEdit = function() {
    var result = '<tr>';
    result += '<td><img src="images/edit_icon_disabled.png">' +
        '<a href="#3" title="Save"><img src="images/save_icon.png" alt="Save"></a></td>';
    result += '<td>' + wizard.makeMetadataSelectBox() + '</td>';
    result += '<td><input type="radio" name="metadata_type">observation<br>';
    result += '<input type="radio" name="metadata_type">perturbation</td>';
    for (var cond in wizard.conditionsAndGroups) {
        result += '<td><input class="metadata-value" type="text"> ';
        result += '<select><option>- units -</option></select></td>';
    }
    result += '</tr>';
    return result;
};

wizard.makeMetadataTable = function() {
    var result = '<table id="metadata-table" style="border: 1px solid black; margin-bottom: 1px;"><tbody>';
    result += '<tr><th>&nbsp;</th><th>Metadata</th><th>Type</th>';
    for (cond in wizard.conditionsAndGroups) {
        result += '<th>' + cond + '</th>';
    }
    result += '</tr>';
    result += wizard.makeMetadataRowForEdit();
    result += '</tbody></table>';
    return result;
};

// ****************************
// **** Application wiring
// ************************

function addStep2EventHandlers() {
    $('#checkall').click(function() {
        $('td :checkbox').attr('checked', $('#checkall').attr('checked'));
    });
    $('#add-selected-conditions').click(wizard.addCheckedConditions);
    $('#create-group').click(function() {
        $('#new-group-dialog').dialog('open');
    });
    $('#apply-grouping').click(wizard.applyGrouping);

    // setup dialog
    $('#new-group-dialog').dialog({title: 'Create Group',
                                   buttons: { 'Ok': function() {
                                       wizard.createAndAddGroup($('#new-group-name').val());
                                       $(this).dialog('close');
                                   },
                                              'Cancel': function() { $(this).dialog('close'); } },
                                   modal: true
                                  });
    $('#new-group-dialog').dialog('close');
}

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
        if (wizard.sbeamsProjectId !== '1064' || wizard.sbeamsTimestamp !== '20100804_163517') {
            console.debug('reloading sbeams information... project: ' + wizard.sbeamsProjectId + ' timestamp: ' +
                          wizard.sbeamsTimestamp);
            $.ajax({
                url: 'import_wizard/conditions_and_groups?project_id=1064&timestamp=20100804_163517',
                dataType: 'json',
                success: function(result) {
                    wizard.conditionsAndGroups = result;
                    wizard.sbeamsProjectId = '1064';
                    wizard.sbeamsTimestamp = '20100804_163517';
                    $(wizard.makeConditionAndGroupsTable()).replaceAll('#condition-list');
                    $(wizard.makeMetadataTable()).replaceAll('#metadata-table');
                }
            });
        }
        wizard.displayStep(2);
    });

    $('#next_2_3').click(function() {
        wizard.displayStep(3);
    });
    $('#prev_2_3').click(function() { history.go(-1); });
    $('#prev_3_3').click(function() { history.go(-1); });

    addStep2EventHandlers();
    $('#add-metadata-row').click(wizard.addMetadataRow);

    // data load
    wizard.reloadGroupSelectBox();
});
