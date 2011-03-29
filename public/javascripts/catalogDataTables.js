/*
* This is used to call the DataTables jquery library and render
* the documents found via search in a DataTable format
*
*/

var oTable;
$(document).ready(function() {
     /* Initialise datatables*/ 
     oTable = $('.dataTable').dataTable({
     	    "bFilter" : false
     }); 
});

function fnShowHide( iCol )
{
	/* Get the DataTables object again - this is not a recreation, just a get of the object */
	var oTable = $('.dataTable').dataTable();
	
	var bVis = oTable.fnSettings().aoColumns[iCol].bVisible;
	oTable.fnSetColumnVis( iCol, bVis ? false : true );
}

