//= require extension

describe("Yammer Extension i18n", function() {
  it("should translate Recognize into correct language", function() {
    var lang = navigator.language;
    var recognize = "Recognise";
    if (navigator.language.indexOf("fr") > -1) {
      recognize = "Reconnaissance";
    } else if (navigator.language.indexOf("US") > -1) {
      recognize = "Recognize";
    }
    expect(window.recognize.patterns.i18n().recognize).toBe(recognize);
  });
});