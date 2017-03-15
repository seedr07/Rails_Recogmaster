//= require extension

describe("Extension objects", function() {
  it("should have core extension objects", function() {
    expect(recognize.patterns.toolbar).toExist();
    expect(window.recognize.file.getPath).toExist();
    expect(window.recognize.host).toExist();
    expect(window.recognize.pages["users-show"]).toExist();
    expect(window.recognize.patterns.api).toExist();
    expect(window.Handlebars).toExist();
  });
});