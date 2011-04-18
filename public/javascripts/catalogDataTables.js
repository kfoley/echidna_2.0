/*
* This is used to call the DataTables jquery library and render
* the documents found via search in a DataTable format
*
*/

var oTable;
$(document).ready(function() {

     /*  collapsing divs js listeners */
     addCollapsingDivListeners(true);

     /* Initialise datatables*/ 
     oTable = $('.dataTable').dataTable({
     	    "bFilter" : false
     }); 

     var i = 0;
     for (i = 0; i < oTable.length; i++) {
    	oTable.dataTableExt.iApiIndex = i;
    	$(oTable.fnGetNodes()).each (function() {
	    var nTds = $('td', this);
	    var c_id = $(nTds[0]).text();
	    /*console.debug('test ' + c_id);*/

            $('td', this).qtip ({
            	    content: {
                    	     text: 'Loading...',
                    	     ajax: {
                    	     url: 'application/condition_names',
                    	     	  type: 'GET',
                    	  	  data: { id: c_id },
                    	  	  dataType: 'json',
                    	  	  success: function(data, status) {
                          	   	  this.set('content.text', data.name);
                    	          }
                    	     }
            	    },
            	    position: {
                    	      my: 'left top',
                    	      at: 'right center'
            	    }
             });
	});
    }
});

function fnShowHide( iCol )
{
	/* Get the DataTables object again - this is not a recreation, just a get of the object */
	var oTable = $('.dataTable').dataTable();
	
	var bVis = oTable.fnSettings().aoColumns[iCol].bVisible;
	oTable.fnSetColumnVis( iCol, bVis ? false : true );
}

