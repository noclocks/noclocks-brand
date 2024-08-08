/**
 * Custom Shiny input bindings for the noclocksrtools package
 * @namespace noclocks
 * @version 0.1.0
 * @license MIT
 * @example
 * # Show an element with a specific class
 * session$sendCustomMessage(type = "showclass", "my-class")
 *
 * # Hide an element with a specific ID
 * session$sendCustomMessage(type = "hideid", "my-id")
 *
 * # Display an alert
 * session$sendCustomMessage(type = 'alert', message = 'This is an alert!')
 *
 * # Display a prompt
 * session$sendCustomMessage(type = 'prompt', message = 'Enter your name:', id = 'name')
 */

$(document).ready(function() {
    /**
     * Shows the specified element(s).
     * @param {string} what - A selector for the element(s) to show.
     */
    Shiny.addCustomMessageHandler('show', function(what) {
      $(what).show();
    });

    /**
     * Hides the specified element(s).
     * @param {string} what - A selector for the element(s) to hide.
     */
    Shiny.addCustomMessageHandler('hide', function(what) {
      $(what).hide();
    });

    /**
     * Shows the element with the specified ID.
     * @param {string} what - The ID of the element to show.
     */
    Shiny.addCustomMessageHandler('showid', function(what) {
      $("#" + what).show();
    });

    /**
     * Hides the element with the specified ID.
     * @param {string} what - The ID of the element to hide.
     */
    Shiny.addCustomMessageHandler('hideid', function(what) {
      $("#" + what).hide();
    });

    /**
     * Shows the elements with the specified class.
     * @param {string} what - The class of the elements to show.
     */
    Shiny.addCustomMessageHandler('showclass', function(what) {
      $("." + what).show();
    });

    /**
     * Hides the elements with the specified class.
     * @param {string} what - The class of the elements to hide.
     */
    Shiny.addCustomMessageHandler('hideclass', function(what) {
      $("." + what).hide();
    });

    /**
     * Shows the links with the specified href attribute.
     * @param {string} what - The href attribute of the links to show.
     */
    Shiny.addCustomMessageHandler('showhref', function(what) {
      $("a[href*=" + what).show();
    });

    /**
     * Hides the links with the specified href attribute.
     * @param {string} what - The href attribute of the links to hide.
     */
    Shiny.addCustomMessageHandler('hidehref', function(what) {
      $("a[href*=" + what).hide();
    });

    /**
     * Simulates a click on the specified element(s).
     * @param {string} what - A selector for the element(s) to click.
     */
    Shiny.addCustomMessageHandler('clickon', function(what) {
      $(what).click();
    });

    /**
     * Disables the specified element(s).
     * @param {string} what - A selector for the element(s) to disable.
     */
    Shiny.addCustomMessageHandler('disable', function(what) {
      $(what).attr('disabled', 'disabled');
    });

    /**
     * Enables the specified element(s).
     * @param {string} what - A selector for the element(s) to enable.
     */
    Shiny.addCustomMessageHandler('reable', function(what) {
      $(what).removeAttr('disabled');
    });

    /**
     * Displays an alert with the specified message.
     * @param {string} message - The message to display in the alert.
     */
    Shiny.addCustomMessageHandler('alert', function(message) {
      alert(message);
    });

    /**
     * Displays a prompt with the specified message and sets the input value in Shiny.
     * @param {Object} args - The arguments for the prompt.
     * @param {string} args.message - The message to display in the prompt.
     * @param {string} args.id - The ID of the Shiny input to set with the prompt's value.
     * @returns {string} The value entered in the prompt.
     */
    Shiny.addCustomMessageHandler('prompt', function(args) {
      var input = prompt(args.message);
      Shiny.setInputValue(args.id, input);
      return input;
    });

    /**
     * Displays a confirmation dialog with the specified message and sets the input value in Shiny.
     * @param {Object} args - The arguments for the confirmation dialog.
     * @param {string} args.message - The message to display in the confirmation dialog.
     * @param {string} args.id - The ID of the Shiny input to set with the confirmation's result.
     * @returns {boolean} The result of the confirmation dialog.
     */
    Shiny.addCustomMessageHandler('confirm', function(args) {
      var input = confirm(args.message);
      Shiny.setInputValue(args.id, input);
      return input;
    });
  });
