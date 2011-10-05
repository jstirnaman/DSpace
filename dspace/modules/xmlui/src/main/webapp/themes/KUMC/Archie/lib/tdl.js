/*
**	Courtesy of Texas Digital Library
**	http://repositories.tdl.org/tdl/themes/TDL/lib/tdl.js
*/

$(document).ready(function(){

	$("div.item_metadata_more").toggle(function(){
		$(this).children(".item_more_text").hide();
		$(this).children(".item_less_text").show();
		$(this).next().slideDown();
	},function(){
		$(this).children(".item_more_text").show();
		$(this).children(".item_less_text").hide();
		$(this).next().slideUp();
	});



});

