/*
 * Echidna Updater.
 * The updater is mostly a Javascript application, backed by a couple
 * of Ajax calls. 
 * The main idea is that the updater object holds all input information until
 * the user hits the final commit. The conversational state is serialized into
 * JSON and submitted to the backend.
 *
 * What gets sent to the backend is a serialized version (JSON) of:
 *
 * - conditions and their metadata
 */
var updater = {
    // an array of groups and conditions collected in the folder
    folderConditions: [],

    // holds the current global term
    // holds the current global type
    globalTerm: '',
    globalType: '',
    techTerm: '',
    techDescr: '',
    metadataTerm: '',
    metadataType: '',
    species: '',

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

    checkedValue: 'sbeams'

};

updater.findConditionAndGroups = function(conditionName) {
    for (var i = 0; i < updater.conditionsAndGroups.length; i++) {
        var condGroup = updater.conditionsAndGroups[i];
        if (condGroup.condition == conditionName) return condGroup;
    }
    return null;
};

// array filter method, predicate is a function that takes (elem, index)
updater.filter = function(array, predicate) {
    var result = [];
    for (var i = 0; i < array.length; i++) {
        if (predicate(array[i], i)) result.push(array[i]);
    }
    return result;
};

updater.displayImportSuccess = function() {
    $('#step1_3').hide();
    $('#step2_3').hide();
    $('#step3_3').hide();
    $('#import_success_report').show();
    $.history.load(4);
};
updater.displayImportFailure = function() {
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
updater.makeGroupString = function(condition) {
    var groups = updater.findConditionAndGroups(condition).groups;
    if (groups.length == 0) return '-';
    var result = '';
    for (var i = 0; i < groups.length; i++) {
        if (i > 0) result += ', ';
        result += groups[i];
    }
    return result;
};

// generates HTML code for the table of imported conditions
updater.makeConditionAndGroupsTable = function() {
    var result = '<table id="condition-list"><tbody>\n';
    for (var i = 0; i < updater.conditionsAndGroups.length; i++) {
        var condition = updater.conditionsAndGroups[i].condition;
        result += '<tr><td class="cond"><input id="' + condition + '" type="checkbox">' + condition +
            '<br>Groups: ' + updater.makeGroupString(condition) + '</td></tr>';
    }
    result += '</tbody></table>';
    return result; 
};

updater.updateConditionAndGroupsTable = function() {
    $(updater.makeConditionAndGroupsTable()).replaceAll('#condition-list');
};

// generates HTML code for the currently selected conditions for grouping
updater.makeSelectedConditionsTable = function() {
    var result = '<table id="selected-conditions"><tbody>\n';
    for (var i = 0; i < updater.selectedConditions.length; i++) {
        var condition = updater.selectedConditions[i];
        result += '<tr><td>' + condition + '&nbsp;<a href="#2" id="delete-selected_' + i + '"><img src="images/delete_icon.png"></a></td></tr>';
    }
    result += '</tbody></table>';
    return result; 
};

updater.updateSelectedConditionsTable = function() {
    $(updater.makeSelectedConditionsTable()).replaceAll('#selected-conditions');
    updater.addDeleteLinkHandlers();
};

updater.removeSelectedAt = function(removeIndex) {
    updater.selectedConditions =  updater.filter(updater.selectedConditions,
                                               function (elem, index) { return index != removeIndex; });
    updater.updateSelectedConditionsTable();
};

// Install handlers for the delete links in the list of selected conditions
updater.addDeleteLinkHandlers = function() {
    // add link handlers
    for (var i = 0; i < updater.selectedConditions.length; i++) {
        $('#delete-selected_' + i).click(function() {
            updater.removeSelectedAt($(this).attr('id').split('_')[1]);
            return false;
        });
    }
};

updater.addCheckedConditions = function() {
    var selected = $('td :checkbox:checked');
    selected.each(function(index, elem) {
        var id = elem.id;
        if ($.inArray(id, updater.selectedConditions) == -1) {
            updater.selectedConditions.push(id);
        }
    });
    selected.attr('checked', false);
    updater.updateSelectedConditionsTable();
    return false;
};

updater.applyGrouping = function() {
    var selectedGroup = $('#all-condition-groups option:selected').val();
    updater.addGroupToSelections(selectedGroup);
};

updater.addGroupToSelections = function(groupName) {
    for (var i = 0; i < updater.selectedConditions.length; i++) {
        var cond = updater.selectedConditions[i];
        var groups = updater.findConditionAndGroups(cond).groups;
        groups.push(groupName);
    }
    // clear selected box
    updater.selectedConditions = [];
    updater.updateSelectedConditionsTable();
    updater.updateConditionAndGroupsTable();
};

updater.createAndAddGroup = function(groupName) {
    updater.allConditionGroups.push(groupName);
    updater.updateGroupSelectBox();
    updater.addGroupToSelections(groupName);
};

updater.updateGroupSelectBox = function() {
    var result = '<select id="all-condition-groups">';
    for (var i = 0; i < updater.allConditionGroups.length; i++) {
        var group = updater.allConditionGroups[i];
        result += '<option value="' + group + '">' + group + '</option>';
    }
    $(result).replaceAll('#all-condition-groups');
};

updater.loadConditionData = function() {
    $.ajax({
        url: 'update/get_condition_metadata',
	dataType: 'json',
	success: function(result) {
	    updater.allMetadata = result;
 	}
    });
};

updater.reloadGroupSelectBox = function() {
    $.ajax({
        url: 'composites/allgroups',
        dataType: 'json',
        success: function(result) {
            updater.allConditionGroups = result;
            updater.updateGroupSelectBox();
        }
    });
};

updater.saveGlobalTerms = function(globalTerm, globalType, techTerm, techDescr) {
    $.ajax({
	url: 'vocabulary/add_new_global_terms?gTerm=' + globalTerm + '&gType=' + globalType + '&techTerm=' +
	    techTerm + '&techDescr=' + techDescr,
	dataType: 'json',
	success: function() {
	    updater.reloadGlobalTermsSelectBox();
	},
	error: function() {
	    console.debug("error inserting new terms");
	}
    });
};

updater.reloadGlobalTermsSelectBox = function() {
    $.ajax({
        url: 'vocabulary/global_terms',
        success: function(result) {
	    $(result).replaceAll('#global-terms');
            //updater.allSpecies = result;
            //updater.updateSpeciesSelectBox();
        }
    });
};

updater.saveMetadataTerms = function(metadataTerm, metadataType) {
    //species = $('#import_species').val();
    $.ajax({
	url: 'vocabulary/add_new_metadata_terms?mTerm=' + metadataTerm + 
	    '&mType=' + metadataType + '&species=' + species,
	dataType: 'json',
	success: function() {
	    updater.reloadMetadataTermsSelectBox();
	},
	error: function() {
	    console.debug("error inserting new metadata terms");
	}
    });
};

updater.reloadMetadataTermsSelectBox = function() {
    species = $('#import_species').val();
    $.ajax({
	url: 'vocabulary/metadata_types?species=' + species,
	success: function(result) {
	    updater.metadataTypes = result;
	    updater.createAndAddMetadata();
	}
    });
};

// *****************************
// *** Step 3 functions
// *********************
updater.addMetadataRow = function() {
    var lastRow = $('#metadata-table tr:last');
    var rowIndex = lastRow.parent().children().index(lastRow);
    lastRow.after(updater.makeMetadataRowForEdit(rowIndex)); //was rowIndex + 1
};

updater.makeSelectBoxFromStringArray = function(index, basename, array, defaultValue) {
    var result = '<select id="' + basename + index +'" name="' + basename + index +'">';
    if (defaultValue != null)  result += '<option value="">' + defaultValue + '</option>';
    for (var i = 0; i < array.length; i++) {
        result += '<option>' + array[i] + '</option>';
    }
    result += '</select>';
    return result;
};

updater.makeMetadataSelectBox = function(index) {
    return updater.makeSelectBoxFromStringArray(index, 'metadata_type_', updater.metadataTypes, null);
};

updater.makeUnitsSelectBox = function(index) {
    return updater.makeSelectBoxFromStringArray(index, 'metadata_unit_', updater.units, '- units -');
};

// generates a metadata row from the conditions we have
updater.makeMetadataRowForEdit = function(rowIndex) {
    var result = '<tr>';
    result += '<td>' + updater.makeMetadataSelectBox(rowIndex) + '</td>';
    result += '<td><input type="radio" name="obspert_' + rowIndex + '" value="observation" checked>observation<br>';
    result += '<input type="radio" name="obspert_' + rowIndex + '" value="perturbation">perturbation</td>';
    //for (var colIndex = 0; colIndex <  updater.conditionsAndGroups.length; colIndex++) {
    //for (var colIndex = 0; colIndex <  updater.folderConditions.length; colIndex++) {
    for (var colIndex = 0; colIndex <  1; colIndex++) {
        var index = rowIndex + '_' + colIndex;
        result += '<td><input name="metadata_value_' + index + '" class="metadata-value" type="text"> ';
        result += updater.makeUnitsSelectBox(index) + '</td>';
    }
    result += '</tr>';
    return result;
};

updater.makeMetadataTable = function() {

//        console.debug("folder length " + updater.folderConditions.length);
//        console.debug("group_id 0 " + updater.folderConditions[0].group_id);
//        console.debug("group_id 1 " + updater.folderConditions[1].group_id);
//        console.debug("group_id 2 " + updater.folderConditions[2].group_id);
//        console.debug("group_id 0 child len " + updater.folderConditions[0].children.length);
//        console.debug("group_id 1 child len " + updater.folderConditions[1].children.length);
//        console.debug("group_id 2 child len " + updater.folderConditions[2].children.length);
//        console.debug("group_id 2 child 0 mdata len " + updater.folderConditions[2].children[0].composite.mdata.length);
//        console.debug("group_id 2 child 0 mdata 0 id " + updater.folderConditions[2].children[0].composite.mdata[0].id);
//        console.debug("group_id 2 child 0 mdata 0 key " + updater.folderConditions[2].children[0].composite.mdata[0].key);
//        console.debug("group_id 2 child 0 mdata 0 val " + updater.folderConditions[2].children[0].composite.mdata[0].value);
//        console.debug("group_id 2 child 0 mdata 0 comp_id " + updater.folderConditions[2].children[0].composite.mdata[0].composite_id);
//        console.debug("test " + updater.folderConditions[i].group_id);	
//        console.debug("test2 " + updater.folderConditions[i].children[i].composite.mdata[2].id);

    var result = '';
    for (var i = 0; i <  updater.folderConditions.length; i++) {
        result += '<div class=\"group-title\">';
	result += updater.folderConditions[i].group_id;
	result += '</div>';
	result += '<table id="metadata-table" style="border: 1px solid black; margin-bottom: 1px;"><tbody>';
	result += '<tr><th>Metadata</th><th>Type</th></tr>';
	result += '<tr>';
	for (var x = 0; x < updater.folderConditions[i].children.length; x++) {
	    result += '<td>';
	    result += '<table id="some-table"><tbody>';
	    result += '<tr><td>';
	    for (var y = 0; y < updater.folderConditions[i].children[x].composite.mdata.length; y++) {
	    	result += '<tr>';
		result += '<td>' + updater.folderConditions[i].children[x].composite.mdata[y].id + '</td>';
		result += '<td>' + updater.folderConditions[i].children[x].composite.mdata[y].key + '</td>';
		result += '<td>' + updater.folderConditions[i].children[x].composite.mdata[y].value + '</td>';
	    	result += '</tr>';
	    }

    	    result += updater.makeMetadataRowForEdit(0);
	    //console.debug("</td>");
	    result += '</tr></td>';
	    result += '</tbody></table>';
	    result += '</td>';
	}
	result += '</tr>';

    	result += '</tbody></table>';
        //result += '<th>' + updater.folderConditions[i].group_id + '</th>';
    }
    //result += '</tr>';

    return result;
};

updater.loadUnits = function() {
    $.ajax({
        url: 'vocabulary/units',
        dataType: 'json',
        success: function(result) {
            updater.units = result;
        }
    });
};
updater.loadMetadataTypes = function() {
    species = $('#import_species').val();
    $.ajax({
        url: 'vocabulary/metadata_types?species=' + species,
        dataType: 'json',
        success: function(result) {
            updater.metadataTypes = result;
        }
    });
};

updater.createAndAddMetadata = function() { //metadataName) {
    var lastRow = $('#metadata-table tr:last');
    var rowIndex = lastRow.index(lastRow);
    for (var i = rowIndex; i < lastRow.index(); i++) {   
    	updater.updateMetadataSelectBox(i); //(rowIndex);
    }
};

updater.updateMetadataSelectBox = function(rowIndex) {
    updater.loadMetadataTypes();
    var result = updater.makeMetadataSelectBox(rowIndex);
    $(result).replaceAll('#metadata_type_' + rowIndex);
};

updater.createProjectIdSelectBox = function() {
    var result = '<select id="sbeams_project_id">'; 
    for (var i = 0; i < updater.projectIds.length; i++) {
        var project = updater.projectIds[i];
        result += '<option value="' + project + '">' + project + '</option>';
    }
    result += '</select>';
    $(result).replaceAll('#sbeams_project_id'); 

    //$('#sbeams_project_id').change(function() {
    //	$.ajax({
	//	url: 'import_updater/get_sbeams_timestamp_dirs?project_id=' + $(this).val(),
        //	dataType: 'json',
        //	success: function(result) {
          //  		 updater.timestamps = result;
	    //		 updater.createTimestampSelectBox();
        //	}
    	//});	
    //});
};

updater.createTimestampSelectBox = function() {
    var result = '<select id="sbeams_timestamp">'; 
    for (var i = 0; i < updater.timestamps.length; i++) {
        var ts_folder = updater.timestamps[i];
        result += '<option value="' + ts_folder + '">' + ts_folder + '</option>';
    }
    result += '</select>';
    $(result).replaceAll('#sbeams_timestamp'); 
};

updater.reloadProjectIdsSelectBox = function() {
    //$.ajax({
//	url: 'import_updater/get_sbeams_project_dirs',
  //      dataType: 'json',
  //      success: function(result) {
   //         updater.projectIds = result;
//	    updater.createProjectIdSelectBox();
 //       }
  //  });
};

updater.createTilingProjectIdSelectBox = function() {
    var result = '<select id="tiling_project_id" disabled>'; 
    for (var i = 0; i < updater.tilingProjectIds.length; i++) {
        var tiling_project = updater.tilingProjectIds[i];
        result += '<option value="' + tiling_project + '">' + tiling_project + '</option>';
    }
    result += '</select>';
    $(result).replaceAll('#tiling_project_id'); 

};

updater.reloadTilingProjectIdsSelectBox = function() {
    $.ajax({
	url: 'import_wizard/get_tiling_project_dirs',
        dataType: 'json',
        success: function(result) {
            updater.tilingProjectIds = result;
	    updater.createTilingProjectIdSelectBox();
        }
    });
};

// ****************************
// **** Submit Data
// ************************
updater.submitData = function() {
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

    if (checkedValue == 'sbeams') {
       submitData.sbeamsProjectId = $('#sbeams_project_id').val();
       submitData.sbeamsTimestamp = $('#sbeams_timestamp').val();
    }
    if (checkedValue == 'tiling') {      
       submitData.tilingProjectId = $('#tiling_project_id').val();
    }

    submitData.conditionsAndGroups = updater.conditionsAndGroups;
    submitData.metadata = [];
    
    for (var row = 0; row < (rows.length - 1); row++) {
        var metadata = {};
        submitData.metadata.push(metadata);
        metadata.metadataType = $('select[name=metadata_type_' + row + ']').val();
        metadata.obspert = $('input[name=obspert_' + row + ']').val();
        metadata.conditionValues = [];
	
        for (var col = 0; col < updater.conditionsAndGroups.length; col++) {
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
        success: function() { updater.displayImportSuccess(); },
        error: function() { updater.displayImportFailure(); }
    });
};

// ****************************
// **** Application wiring
// ************************
function addStep1EventHandlers() {
    $('#import_species').click(function() {
    	species = $('#import_species').val();
    });

    $('#import_vocab_type').click(function() {
	if ($('#import_vocab_type').val() == 'technology') {
	    console.debug('clicked = ' + $('#import_vocab_type').val());
	} else {
	    console.debug('you did not choose technology');
	}

    });

    $('#create-global-term').click(function() {
        $('#new-global-dialog').dialog('open');
    });

    // setup dialog
    $('#new-global-dialog').dialog({title: 'Create Global Term',
                                   buttons: { 'Ok': function() {
                                       updater.saveGlobalTerms(
					   $('#new-global-name').val(),
					   $('#import_vocab_type').val(),
					   $('#import_tech_desc').val(),
					   $('#new-global-techD').val());
                                       $(this).dialog('close');
                                   },
                                              'Cancel': function() { $(this).dialog('close'); } },
                                   modal: true,
				   width: '500'
                                  });
    $('#new-global-dialog').dialog('close');

}

function addStep2EventHandlers() {
    $('#checkall').click(function() {
        $('td :checkbox').attr('checked', $('#checkall').attr('checked'));
    });
    $('#add-selected-conditions').click(updater.addCheckedConditions);
    $('#create-group').click(function() {
        $('#new-group-dialog').dialog('open');
    });
    $('#apply-grouping').click(updater.applyGrouping);

    // setup dialog
    $('#new-group-dialog').dialog({title: 'Create Group',
                                   buttons: { 'Ok': function() {
                                       updater.createAndAddGroup($('#new-group-name').val());
                                       $(this).dialog('close');
                                   },
                                              'Cancel': function() { $(this).dialog('close'); } },
                                   modal: true,
				   width: '500'
                                  });
    $('#new-group-dialog').dialog('close');
}

function addStep3EventHandlers() {
    $('#add-metadata-term').click(function() {
        $('#new-metadata-dialog').dialog('open');
    });

    // setup dialog
    $('#new-metadata-dialog').dialog({title: 'Add New Metadata',
                                   buttons: { 'Ok': function() {
				       updater.saveMetadataTerms(
					   $('#new-metadata-name').val(),
					   $('#import_meta_type').val());
                                       $(this).dialog('close');
                                   },
                                              'Cancel': function() { $(this).dialog('close'); } },
                                   modal: true,
				   width: '500'
                                  });
    $('#new-metadata-dialog').dialog('close');
}

updater.displayErrorBox = function(messages) {
    var message = '<div id="errorbox" class="updater-form-row errorbox">';
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
    $('#update_success_report').hide();
    $('#update_error_report').hide();

    // fetch and load data
    $.ajax({
        url: 'update/folder_contents',
	dataType: 'json',
	success: function(result) {
	    console.debug('ajax result ' + result);
	    updater.folderConditions = result;
	    $(updater.makeMetadataTable()).replaceAll('#metadata-table');
	},
	error: function() {
	    updater.displayErrorBox(['Server down or faulty folder contents information']);
	}
    
    });
    //updater.createProjectIdSelectBox();
    //updater.createTilingProjectIdSelectBox();

    addStep3EventHandlers();

    $('#add-metadata-row').click(updater.addMetadataRow);

    $('#submit-data').click(updater.submitData);


    // data load
    //updater.reloadGlobalTermsSelectBox();
    //updater.reloadProjectIdsSelectBox();
    //updater.reloadTilingProjectIdsSelectBox();
    //updater.reloadGroupSelectBox();
    updater.loadUnits();

});
