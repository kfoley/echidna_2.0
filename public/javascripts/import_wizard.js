/*
 * Echidna Import Wizard.
 * The import wizard is mostly a Javascript application, backed by a couple
 * of Ajax calls. It uses the jquery.history.js plugin to support back button
 * functionality.
 * The main idea is that the wizard object holds all input information until
 * the user hits the final commit. The conversational state is serialized into
 * JSON and submitted to the backend.
 * What get sent to the backend is a serialized version (JSON) of:
 *
 * - conditionsAndGroups
 * - metadata
 */
var wizard = {
    // an array of entries { condition: <name>, groups: <groups>}
    conditionsAndGroups: [],

    // an array of strings containing all condition groups
    allConditionGroups: [],

    // holds the current SBEAMS project id
    // holds the current SBEAMS timestamp
    // holds the current tiling project id
    sbeamsProjectId: '',
    sbeamsTimestamp: '',
    tilingProjectId: '',

    // holds the currently selected condition names contained in the
    // group assign step. It is cleared after groups were assigned
    selectedConditions: [],
    
    // a row in metadata holds entries of
    // { 'key': <somekey>, 'type': <observation|perturbation>, <condition 1>: [<value>, <unit>], ... }
    metadata: [],

    // loaded at page load time, we generate select boxes out of them
    metadataTypes: [],
    units: [],

    // contains all the project ids from sbeams pipeline directory
    projectIds: [],

    // contains all the timestamp folders from sbeams pipeline/project_id directory
    timestamps: [],

    // contains all the project ids from the tiling directory on bragi
    tilingProjectIds: [],

    checkedValue: ''

};

wizard.findConditionAndGroups = function(conditionName) {
    for (var i = 0; i < wizard.conditionsAndGroups.length; i++) {
        var condGroup = wizard.conditionsAndGroups[i];
        if (condGroup.condition == conditionName) return condGroup;
    }
    return null;
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
wizard.displayImportSuccess = function() {
    $('#step1_3').hide();
    $('#step2_3').hide();
    $('#step3_3').hide();
    $('#import_success_report').show();
    $.history.load(4);
};
wizard.displayImportFailure = function() {
    $('#step1_3').hide();
    $('#step2_3').hide();
    $('#step3_3').hide();
    $('#import_error_report').show();
    $.history.load(4);
}

// *****************************
// *** Step 2 functions
// *********************
// computes a string representing a list of groups associated with a condition
wizard.makeGroupString = function(condition) {
    var groups = wizard.findConditionAndGroups(condition).groups;
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
    for (var i = 0; i < wizard.conditionsAndGroups.length; i++) {
        var condition = wizard.conditionsAndGroups[i].condition;
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
    wizard.addGroupToSelections(selectedGroup);
};

wizard.addGroupToSelections = function(groupName) {
    for (var i = 0; i < wizard.selectedConditions.length; i++) {
        var cond = wizard.selectedConditions[i];
        var groups = wizard.findConditionAndGroups(cond).groups;
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
    var lastRow = $('#metadata-table tr:last');
    var rowIndex = lastRow.parent().children().index(lastRow);
    lastRow.after(wizard.makeMetadataRowForEdit(rowIndex + 1));
};

wizard.makeSelectBoxFromStringArray = function(index, basename, array, defaultValue) {
    var result = '<select name="' + basename + index +'">';
    if (defaultValue != null)  result += '<option value="">' + defaultValue + '</option>';
    for (var i = 0; i < array.length; i++) {
        result += '<option>' + array[i] + '</option>';
    }
    result += '</select>';
    return result;
};

wizard.makeMetadataSelectBox = function(index) {
    return wizard.makeSelectBoxFromStringArray(index, 'metadata_type_', wizard.metadataTypes, null);
};

wizard.makeUnitsSelectBox = function(index) {
    return wizard.makeSelectBoxFromStringArray(index, 'metadata_unit_', wizard.units, '- units -');
};

// generates a metadata row from the conditions we have
wizard.makeMetadataRowForEdit = function(rowIndex) {
    var result = '<tr>';
    result += '<td>' + wizard.makeMetadataSelectBox(rowIndex) + '</td>';
    result += '<td><input type="radio" name="obspert_' + rowIndex + '" value="observation" checked>observation<br>';
    result += '<input type="radio" name="obspert_' + rowIndex + '" value="perturbation">perturbation</td>';
    for (var colIndex = 0; colIndex <  wizard.conditionsAndGroups.length; colIndex++) {
        var index = rowIndex + '_' + colIndex;
        result += '<td><input name="metadata_value_' + index + '" class="metadata-value" type="text"> ';
        result += wizard.makeUnitsSelectBox(index) + '</td>';
    }
    result += '</tr>';
    return result;
};

wizard.makeMetadataTable = function() {
    var result = '<table id="metadata-table" style="border: 1px solid black; margin-bottom: 1px;"><tbody>';
    result += '<tr><th>Metadata</th><th>Type</th>';
    for (var i = 0; i <  wizard.conditionsAndGroups.length; i++) {
        result += '<th>' + wizard.conditionsAndGroups[i].condition + '</th>';
    }
    result += '</tr>';
    result += wizard.makeMetadataRowForEdit(0);
    result += '</tbody></table>';
    return result;
};

wizard.loadUnits = function() {
    $.ajax({
        url: 'vocabulary/units',
        dataType: 'json',
        success: function(result) {
            wizard.units = result;
        }
    });
};
wizard.loadMetadataTypes = function() {
    $.ajax({
        url: 'vocabulary/metadata_types',
        dataType: 'json',
        success: function(result) {
            wizard.metadataTypes = result;
        }
    });
};

wizard.createProjectIdSelectBox = function() {
    var result = '<select id="sbeams_project_id">'; 
    for (var i = 0; i < wizard.projectIds.length; i++) {
        var project = wizard.projectIds[i];
        result += '<option value="' + project + '">' + project + '</option>';
    }
    result += '</select>';
    $(result).replaceAll('#sbeams_project_id'); 

    $('#sbeams_project_id').change(function() {
    	$.ajax({
		url: 'import_wizard/get_sbeams_timestamp_dirs?project_id=' + $(this).val(),
        	dataType: 'json',
        	success: function(result) {
            		 wizard.timestamps = result;
	    		 wizard.createTimestampSelectBox();
        	}
    	});	
    });
};

wizard.createTimestampSelectBox = function() {
    var result = '<select id="sbeams_timestamp">'; 
    for (var i = 0; i < wizard.timestamps.length; i++) {
        var ts_folder = wizard.timestamps[i];
        result += '<option value="' + ts_folder + '">' + ts_folder + '</option>';
    }
    result += '</select>';
    $(result).replaceAll('#sbeams_timestamp'); 
};

wizard.reloadProjectIdsSelectBox = function() {
    $.ajax({
	url: 'import_wizard/get_sbeams_project_dirs',
        dataType: 'json',
        success: function(result) {
            wizard.projectIds = result;
	    wizard.createProjectIdSelectBox();
        }
    });
};

wizard.createTilingProjectIdSelectBox = function() {
    var result = '<select id="tiling_project_id" disabled>'; 
    for (var i = 0; i < wizard.tilingProjectIds.length; i++) {
        var tiling_project = wizard.tilingProjectIds[i];
        result += '<option value="' + tiling_project + '">' + tiling_project + '</option>';
    }
    result += '</select>';
    $(result).replaceAll('#tiling_project_id'); 

};

wizard.reloadTilingProjectIdsSelectBox = function() {
    $.ajax({
	url: 'import_wizard/get_tiling_project_dirs',
        dataType: 'json',
        success: function(result) {
            wizard.tilingProjectIds = result;
	    wizard.createTilingProjectIdSelectBox();
        }
    });
};

wizard.submitData = function() {
    var lastRow = $('#metadata-table tr:last');
    var table = lastRow.parent();
    var rows = table.children();
    // in this table, row 0 is the header, so there are (rows.length - 1) data rows
    var submitData = {};
    submitData.species = $('#import_species').val();
    submitData.dataType = $('#import_datatype').val();
    submitData.slideType = $('#import_slidetype').val();
    submitData.platform = $('#import_platform').val();
    submitData.slideFormat = $('#import_slideformat').val();

    submitData.sbeamsProjectId = $('#sbeams_project_id').val();
    submitData.sbeamsTimestamp = $('#sbeams_timestamp').val();
    submitData.conditionsAndGroups = wizard.conditionsAndGroups;
    submitData.metadata = [];
    
    for (var row = 0; row < (rows.length - 1); row++) {
        var metadata = {};
        submitData.metadata.push(metadata);
        metadata.metadataType = $('select[name=metadata_type_' + row + ']').val();
        metadata.obspert = $('input[name=obspert_' + row + ']').val();
        metadata.conditionValues = [];
        for (var col = 0; col < wizard.conditionsAndGroups.length; col++) {
            var value = { };
            metadata.conditionValues.push(value);
            value.value =  $('input[name=metadata_value_' + row + '_' + col + ']').val();
            value.unit  =  $('select[name=metadata_unit_' + row + '_' + col + ']').val();
        }
    }
    // use json2.js to turn the data into JSON
    var jsonStr = JSON.stringify(submitData);
    $.ajax({
        type: 'POST',
        url: 'import_wizard/import_data',
        data: {import_data: jsonStr},
        success: function() { wizard.displayImportSuccess(); },
        error: function() { wizard.displayImportFailure(); }
    });
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

wizard.displayStep1ErrorBox = function(messages) {
    var message = '<div id="step1-errorbox" class="wizard-form-row errorbox">';
    message += 'Error while loading SBEAMS information <ul>';
    for (var i = 0; i < messages.length; i++) {
        message += '<li>' + messages[i] + '</li>';
    }
    message += '</ul></div>';
    $(message).replaceAll('#step1-errorbox');
    $('#step1-errorbox').show();
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
    $('#step1-errorbox').hide();
    $('#import_success_report').hide();
    $('#import_error_report').hide();

    wizard.createProjectIdSelectBox();
    wizard.createTilingProjectIdSelectBox();

    var checkedValue = 'sbeams';
    console.debug('checkedValue1: ' + checkedValue);
    $("input:radio[@name=input_type]").click(function() {
       checkedValue = $(this).val();

       if (checkedValue == 'sbeams') {
           console.debug('changed to: ' + checkedValue);
	   $("#sbeams_project_id").attr('disabled',false);	   
	   $("#sbeams_timestamp").attr('disabled',false);	   
	   $("#tiling_project_id").attr('disabled',true);
       } else if (checkedValue == 'tiling') {
           console.debug('changed to: ' + checkedValue);
	   $("#tiling_project_id").attr('disabled',false);
	   $("#sbeams_project_id").attr('disabled',true);	   
	   $("#sbeams_timestamp").attr('disabled',true);	   
       } else {
          //alert('You haven't chosen a project');   
       }	        
    });


    $('#next_1_3').click(function() {
        var sbeamsProjectId = $('#sbeams_project_id').val();
        var sbeamsTimestamp = $('#sbeams_timestamp').val();
	var tilingProjectId = $('#tiling_project_id').val();

           console.debug('sbeamsProjId: ' + sbeamsProjectId);	
           console.debug('sbeamsTimestamp: ' + sbeamsTimestamp);
           console.debug('tilingProjId: ' + tilingProjectId);		
           console.debug('checked value: ' + checkedValue);        
	if (checkedValue == 'sbeams') {
            if (sbeamsProjectId == '' || sbeamsTimestamp == '') {
                wizard.displayStep1ErrorBox(['SBEAMS project or timestamp missing']);
            } else if (wizard.sbeamsProjectId != sbeamsProjectId ||
                       wizard.sbeamsTimestamp != sbeamsTimestamp) {
                $('#step1-errorbox').hide();
                $.ajax({
                    url: 'import_wizard/conditions_and_groups_sbeams?project_id=' + sbeamsProjectId +
                        '&timestamp=' + sbeamsTimestamp,
                    dataType: 'json',
                    success: function(result) {
                        wizard.conditionsAndGroups = result;
                        wizard.sbeamsProjectId = sbeamsProjectId;
                        wizard.sbeamsTimestamp = sbeamsTimestamp;
                        $(wizard.makeConditionAndGroupsTable()).replaceAll('#condition-list');
                        $(wizard.makeMetadataTable()).replaceAll('#metadata-table');
                        wizard.displayStep(2);
                    },
                    error: function() {
                        wizard.displayStep1ErrorBox(['Server down or faulty SBEAMS information']);
                    }
                });
	    } else {
                wizard.displayStep(2);
            }
	} else {
            if (tilingProjectId == '') {
                wizard.displayStep1ErrorBox(['Tiling project missing']);
            } else if (wizard.tilingProjectId != tilingProjectId) {
                $('#step1-errorbox').hide();
                $.ajax({
                    url: 'import_wizard/conditions_and_groups_tiling?project_id=' + tilingProjectId,
                    dataType: 'json',
                    success: function(result) {
                        wizard.conditionsAndGroups = result;
                        wizard.tilingProjectId = tilingProjectId;
                        $(wizard.makeConditionAndGroupsTable()).replaceAll('#condition-list');
                        $(wizard.makeMetadataTable()).replaceAll('#metadata-table');
                        wizard.displayStep(2);
                    },
                    error: function() {
                        wizard.displayStep1ErrorBox(['Server down or faulty Tiling information']);
                    }
                });
	    } else {
                wizard.displayStep(2);
            }
        }
    });

    $('#next_2_3').click(function() {
        wizard.displayStep(3);
    });
    $('#prev_2_3').click(function() { history.go(-1); });
    $('#prev_3_3').click(function() { history.go(-1); });

    addStep2EventHandlers();
    $('#add-metadata-row').click(wizard.addMetadataRow);

    $('#submit-data').click(wizard.submitData);



    // data load
    wizard.reloadProjectIdsSelectBox();
    wizard.reloadTilingProjectIdsSelectBox();
    wizard.reloadGroupSelectBox();
    wizard.loadUnits();
    wizard.loadMetadataTypes();

});
