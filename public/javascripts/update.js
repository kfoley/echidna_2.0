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

    // holds the current species
    species: '',
    metadataTerm: '',
    metadataType: '',

    // a row in metadata holds entries of
    // { 'key': <somekey>, 'type': <observation|perturbation>, <condition 1>: [<value>, <unit>], ... }
    metadata: [],

    // loaded at page load time, we generate select boxes out of them
    metadataTypes: [],
    units: []

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
    //species = $('#import_species').val();
    $.ajax({
	url: 'vocabulary/metadata_types?species=' + updater.species,
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
        if (array[i] == defaultValue) {
	    array[i].selected = true;
	}
        result += '<option>' + array[i] + '</option>';
    }
    result += '</select>';
    return result;
};

updater.makeMetadataSelectBox = function(index, myDefault) {
    return updater.makeSelectBoxFromStringArray(index, 'metadata_type_', updater.metadataTypes, myDefault);
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
    var result = '';
    for (var i = 0; i <  updater.folderConditions.length; i++) {
        result += '<div class=\"group-title\">Group Name <br />';
	result += updater.folderConditions[i].group_id + ': ' + updater.folderConditions[i].g_name;
	result += '</div>';
	result += '<table id="update-metadata-table" style="border: 1px solid black;"><tbody>';
	result += '<tr>';
	for (var x = 0; x < updater.folderConditions[i].children.length; x++) {
	    species = updater.folderConditions[i].children[x].composite.species;
	    updater.loadMetadataTypes();
	    //console.debug('inside make metadata table');
	    result += '<td>';
	    result += '<table id="update-meta-values"><tbody>';
	    result += '<tr>' + updater.folderConditions[i].children[x].composite.name + '</tr>';
	    result += '<tr><th width="50%">Metadata Category</th><th width="50%">Metadata</th><th width="0%"></th></tr>';
	    result += '<tr><td>';
	    for (var y = 0; y < updater.folderConditions[i].children[x].composite.mdata.length; y++) {
	    	result += '<tr>';
		//result += updater.folderConditions[i].children[x].composite.mdata[y].key + '</td>';
		index = updater.folderConditions[i].children[x].composite.mdata[y].id;
		myDefault = updater.folderConditions[i].children[x].composite.mdata[y].key;
		if (myDefault == 'species') {
		    result += '<td><input id="prop_key_0" type="text" disabled="disabled" value="' + updater.folderConditions[i].children[x].composite.mdata[y].key + '" /></td>';
		    result += '<td><input id="prop_val_0" value="' + updater.folderConditions[i].children[x].composite.mdata[y].value + '" type="text" disabled="disabled"></td><td></td>';
		} else {
		    result += '<td><a href="#" class="del-button" id="' + updater.folderConditions[i].children[x].composite.mdata[y].id + '" class="delete"><img src="images/delete_icon.png" alt="delete"></a><input id="cp_id" value="' + updater.folderConditions[i].children[x].composite.mdata[y].id + '" type="hidden">';
		    result += updater.makeMetadataSelectBox(index,myDefault);
		    result += '</td>';
		    result += '<td><input id="prop_val_' + index + '" value="' + updater.folderConditions[i].children[x].composite.mdata[y].value + '" type="text"></td><td></td>';
		}
	    	result += '</tr>';
	    }

    	    result += updater.makeMetadataRowForEdit(0);
	    result += '</tr></td>';
	    result += '</tbody></table>';
	    result += '</td>';
	}
	result += '</tr>';
    	result += '</tbody></table>';
    }

    return result;
};

updater.updateMetadataSelectBoxes = function() {
    for (var i = 0; i <  updater.folderConditions.length; i++) {
	for (var x = 0; x < updater.folderConditions[i].children.length; x++) {
	    species = updater.folderConditions[i].children[x].composite.species;
	    updater.loadMetadataTypes();
	    for (var y = 0; y < updater.folderConditions[i].children[x].composite.mdata.length; y++) {
		index = updater.folderConditions[i].children[x].composite.mdata[y].id;
		myDefault = updater.folderConditions[i].children[x].composite.mdata[y].key;	        
		selbox = updater.makeSelectBoxFromStringArray(index, 'metadata_type_', updater.metadataTypes, myDefault);
		$(selbox).replaceAll('#metadata_type_' + index);
	    }
	}
    }    
};

updater.updateMetadataTable = function() {
    $(updater.makeMetadataTable()).replaceAll('#update-metadata-table');
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
	    //console.debug('loadmetadata SUCCESS' + result);
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

updater.getFolderData = function() {

    // fetch and load data
    $.ajax({
        url: 'update/folder_contents',
	dataType: 'json',
	success: function(result) {
	    updater.folderConditions = result;
	    $(updater.makeMetadataTable()).replaceAll('#metadata-table');
	    updater.updateMetadataSelectBoxes();
	},
	error: function() {
	    updater.displayErrorBox(['Server down or faulty folder contents information']);
	}
    
    });

};

updater.testFunction = function() {
    console.debug('test = ' + updater.folderConditions);
};

// Application entry point
$(document).ready(function() {
    $('#update_success_report').hide();
    $('#update_error_report').hide();
    
    updater.getFolderData();
    updater.testFunction();
    //$(updater.makeMetadataTable()).replaceAll('#metadata-table');

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
    //updater.reloadMetadataTermsSelectBox();
    updater.loadMetadataTypes();
    updater.loadUnits();

});
