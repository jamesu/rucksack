// Import and register all your controllers from the importmap under controllers/*

import QUnit from "qunit";
import TestJournalHelpers from "./test_journal_helpers.js"

window.tests = [
	TestJournalHelpers
	];


document.addEventListener('DOMContentLoaded', () => {
	TestJournalHelpers(window.QUnit);

	window.QUnit.start();
});

