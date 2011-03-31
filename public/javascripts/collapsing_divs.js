function addCollapsingDivListeners(openMultiple) {
	// assumes toShowHide array exists
	
	var toShowHide = new Array();
	$('.showhide').each(
	function() {
		var name_ = this.id.split("_");
		name_.shift();
		var name = name_.join("_");
	console.debug("toshowhide names = " + name);	
		toShowHide.push(name);
	});

	var first = true;

	// hide everything by default
	// and setup the event listeners
	for (var i = 0; i < toShowHide.length; i++) {
		var childName = toShowHide[i];
		var childID = "#"+childName;
		var parentID = "#showhide_"+toShowHide[i];
		var child = $(childID);
		
		console.debug("child name = " + childName);
		console.debug("child id = " + "#"+childName);
		console.debug("parent id = " + "#showhide_"+toShowHide[i]);		
		console.debug("child  = " + child);

		if (child.length != 0) {
			if (first)
				first = false;
			else
				child.hide();
			$(parentID).css('cursor', 'pointer');
			$(parentID).bind('click', {'name': childName, 'mul': openMultiple}, function(e) {
				if ($("#"+e.data['name']).is(":visible")) {
					$("#"+e.data['name']).slideUp('fast');
				} else {
					$("#"+e.data['name']).slideDown('fast');
				}
				if (!e.data['mul']) {
					closeOthers(e.data, toShowHide);
				}
			});
		}
	}
}

function closeOthers(nameToPreserve, all) {
	for (var i = 0; i < all.length; i++) {
		if (all[i] != nameToPreserve)
			$("#"+all[i]).hide('fast');
	}
}