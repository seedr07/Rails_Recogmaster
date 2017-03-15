window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["companies-show"] = (function() {
  var companyScope;

  function getURL(path) {
    return '/' + companyScope + path;
  }

  var Company = function() {
    var uploader, that = this;
    companyScope = $body.data('companyScope');

    this.addEvents();
    showCurrentTab();

    if ($("#company-admin-content-wrapper.paid").length == 0) {
      this.lockUnpaidCompanyAdmin();
      return
    }

    this.$userTable = $("#user-set-wrapper");
    uploader = new window.R.Uploader($("#new_badge"), function(e, json) {
      $("#new_badge")[0].reset();
      var $newBadge = $(json.partial);
      $newBadge.hide().prependTo("#active-badges-wrapper").fadeIn("slow");
      that.setupBadges($newBadge);
    });

    this.initGraphs();
    this.setupAccountsTab();
    this.setupRewardsTab();
    this.setupTopEmployeesTab();

    var companyAdmin = new R.CompanyAdmin();
  };

  Company.prototype.addResGauge = function() {
    this.resId = "res-score";
    var $res = $("#" + this.resId);

    if ($res.children().length > 0) {
      $res.empty();
    }

    this.res = new JustGage({
      id: this.resId,
      value: $res.data('res'),
      min: 0,
      max: 100,
      symbol: "%",
      customSectors: [{
        color: "#FF0000",
        lo: 0,
        hi: 25
      }, {
        color: "#FFff00",
        lo: 25,
        hi: 50,
      }, {
        color: "#06ff00",
        lo: 50,
        hi: 75,
      }, {
        color: "#41a0d9",
        lo: 75,
        hi: 100
      }]
    });
  };

  Company.prototype.removeEvents = function() {
    delete this.res;
    $window.unbind('ajaxify:success:edit_bulk_user_updater');
    $window.unbind('ajaxify:error:edit_bulk_user_updater');
    $document.off('click', "a#edit-accounts");
    $("#accounts").off();
    $("#accounts").unbind();
    $document.off('click', "#add-account");
    $document.off('click', "#leave-edit-accounts");
    $document.off(R.touchEvent, ".reward-card .close-icon");
    $document.off("click", ".add-reward-card");
    $("#rewards").off("pageletLoaded");
    $(".reward-manager-select").off();
    if (this.$companyWrapper) {
      this.$companyWrapper.off('change mousedown touchstart');
      this.$companyWrapper.off('click');
    }

    $("#custom-badges-disabled-link").unbind();
    $('a[data-toggle="tab"]').off('shown');

    $document.off("ajax:success", '.new_reward');

    if (this.$pointValues) {
      this.$pointValues.unbind("ajax:complete");
      this.$pointValues.unbind("ajax:complete");
    }

    $window.unbind("ajaxify:success:kioskUrlUpdated");
    $document.off("ajax:success", '.edit_reward');
    $(".badge-type-selectors input[type='radio']").off();
    $document.off('click', '.role_toggle');
    $document.off('click', '#all_teams_box');
  };

  function showCurrentTab() {
    var url = document.location.toString();
    if (url.match('#')) {
      var tab = url.split('#')[1];
      if (tab === "custom-badge-upload") {
        tab = "custom_badges";
        if ($("#custom_badges .drawer-trigger").length) {
          $("#custom_badges .drawer-trigger").click();
        } else {
          $(function() {
            $("#custom_badges .drawer-trigger").click();
          });
        }

      }
      $('a[data-toggle="tab"][href=#' + tab + ']').tab('show');
    }
  }

  function promptToPay(e) {
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();

    swal({
        imageUrl: "/assets/badges/100/powerful.png",
        title: "Engage your staff",
        // text: "By upgrading to a paid package of Recognize, you can maximize its success through customizations and integration. Upgrade to start your movement. If you have any questions, <a href='/contact'>contact us</a>",
        text: 'Successful companies using Recognize customized their badges and more. Upgrade to start customizing.',
        showCancelButton: true,
        confirmButtonColor: "#5cc314",
        cancelButtonText: "I'll think about it",
        confirmButtonText: "Upgrade",
        html: true,
        animation: "slide-from-top"
      },
      function(isConfirm) {
        if (isConfirm) {
          window.location = '/welcome/?upgrade=true';
        }
      }
    )
  }

  function formatUser(user) {
    if (user.loading) return "Please wait";

    var markup = '<div class="clearfix">' +
      '<div class="col-sm-1">' +
      '<img src="' + user.avatar_thumb_url + '" style="max-width: 100%" />' +
      '</div>' +
      '<div clas="col-sm-10">' +
      '<div class="clearfix">' +
      '<div class="col-sm-6">' + user.label + '</div>' +
      '</div>';

    markup += '</div></div>';

    return markup;
  }

  function formatUserSelection(user) {
    return user.label || user.text;
  }

  Company.prototype.setupAccountsTab = function() {
    this.bindEditAccountsBtn();
    this.bindAccountsPagelet();
    this.bindLeaveEditAccountsBtn();
    this.bindAccountsSuccess();
    this.bindAccountsError();
    this.bindAccountsFormChangeHandler();
    this.bindAddAccountBtn();
    this.bindRolesSelect();
  };

  Company.prototype.bindRolesSelect = function() {
    $("#accounts").bind('pageletLoaded', function() {
      new window.R.Select2(function() {
        $('.user-company-role-select').select2({
          tokenSeparators: [',', ' ']
        });

        $document.on('select2:select', '.user-company-role-select', function(event) {
          $.ajax({
            url: $(this).data("url"),
            data: { role_name: event.params.data.text },
            method: "post"
          });
        });

        $document.on('select2:unselect', '.user-company-role-select', function(event) {
          $.ajax({
            url: $(this).data("url"),
            data: { role_name: event.params.data.text },
            method: "delete"
          });
        });
      });
    });
  };

  Company.prototype.bindEditAccountsBtn = function() {
    var that = this;

    $.fn.dataTable.ext.order['dom-checkbox'] = function(settings, col) {
      return this.api().column(col, { order: 'index' }).nodes().map(function(td, i) {
        return $('input', td).prop('checked') ? '1' : '0';
      });
    }

    $document.on('click', "a#edit-accounts", function(e) {
      e.preventDefault();

      var url = $(e.target).attr('href');
      window.recognize.patterns.formLoading.setNonAjaxButton(e);

      $("#accounts").load(url + " #wrapper-outer .wrapper", function() {
        window.recognize.patterns.formLoading.resetButton();
        that.initializeEditAccountDataTable();
      });
      return false;
    })
  };

  Company.prototype.bindAccountsFormChangeHandler = function() {
    $document.on("change", "input[type=checkbox]", function() {
      $(this).parents("tr").removeClass("selected");
    });

    $("#accounts").on("change keyup", "input:not([type=checkbox]), select", function() {
      var $row = $(this).parents("tr");
      $row.addClass("selected");
      $row.find("input[type=checkbox]").attr('checked', true);
    });
  };

  Company.prototype.bindAccountsPagelet = function() {
    $("#accounts").bind('pageletLoaded', function() {
      var $table = $('#user-set');
      $table.DataTable({
        ordering: true,
        paging: true,
        searching: true,
        responsive: true,
        pageLength: 100

      });
    })
  };

  Company.prototype.bindAddAccountBtn = function() {
    var that = this;
    $document.on('click', "#add-account", function() {
      var $addBtn = $(this);
      var time = new Date().getTime();

      var id = $addBtn.data('id');
      var template = $addBtn.data('newAccountTemplate');

      var regexp = new RegExp(id, 'g');

      var table = $("#edit-accounts table").dataTable();
      var rowHtml = template.replace(regexp, time);
      rowHtml = rowHtml.replace(/SK\-.*\-SK/, "_SK-" + time + "-SK");

      table.api().row.add($(rowHtml)[0]).draw();
    })
  };

  Company.prototype.bindAccountsSuccess = function() {
    $window.bind('ajaxify:success:edit_bulk_user_updater', function(e, successObj) {
      var numAccountsCreated = successObj.data.bulk_user_updater.created_users.length;
      var numAccountsUpdated = successObj.data.bulk_user_updater.updated_users.length;
      var msg;

      if (numAccountsCreated > 0) {
        // need to update the rows for created records and make them "updates"
        $.each(successObj.data.bulk_user_updater.created_users, function() {
          var $row = $("#user-row-" + this.temporary_id),
            temporary_id = this.temporary_id,
            actual_id = this.id;

          var table = $("#edit-accounts table").dataTable().api();

          $row.find("td").each(function() {
            var $cellEl = $(this);
            $cellEl.find("input").each(function() {
              $(this).attr("value", $(this).val());
            });

            var cellHTMLStr = $cellEl.html().replace(new RegExp(temporary_id, 'g'), actual_id);
            cellHTMLStr = cellHTMLStr.replace(new RegExp('create', 'g'), 'update');
            table.cell(this).data(cellHTMLStr);
          });

        })
      }

      if (numAccountsCreated == 0 && numAccountsUpdated == 0) {
        msg = "No accounts were modified";
      } else if (numAccountsCreated > 0 && numAccountsUpdated > 0) {
        msg = numAccountsCreated + " accounts created, and " + numAccountsUpdated + " accounts updated";
      } else if (numAccountsCreated > 0) {
        msg = numAccountsCreated + " accounts created";
      } else {
        msg = numAccountsUpdated + " accounts updated";
      }

      successFeedback(msg, $("#edit-accounts #response-feedback-wrapper"));
    })
  };

  Company.prototype.bindAccountsError = function() {
    $window.bind('ajaxify:errors:edit_bulk_user_updater', function(e, successObj) {
      $("#edit-accounts table").dataTable().fnSort([2, 'desc']);
    });
  };

  Company.prototype.bindLeaveEditAccountsBtn = function() {
    $document.on('click', "#leave-edit-accounts", function(e) {
      e.preventDefault();
      var url = $(e.target).attr('href');
      window.recognize.patterns.formLoading.setNonAjaxButton(e);
      $("#accounts").load(url + " #wrapper-outer .wrapper");
      return false;
    });

  };

  Company.prototype.initializeEditAccountDataTable = function() {

    var columnSpec = [
      {}, { "orderDataType": "dom-checkbox" }, {}, {}, {}, {}, {}, {}
    ];

    $("#edit-accounts table").DataTable({
      ordering: true,
      paging: true,
      searching: true,
      responsive: true,
      pageLength: 100,
      "columnDefs": [{ "orderDataType": "dom-checkbox", targets: [2] }]
    })
  };

  function addRewardImage(e, data) {
    this.find(".reward-image").attr("src", data.reward.image.url);
  }

  Company.prototype.setupRewardsTab = function() {
    var that = this;

    $document.on(R.touchEvent, ".reward-card .close-icon", function(e) {
      that.removeRewardCard(e);
    });

    $document.on("click", ".add-reward-card", function(e) {
      that.addRewardCard(e);
    });

    $("#rewards").on("pageletLoaded", function() {
      new window.R.Select2(this.bindRewardManagerAutocomplete);

      $("#reward-tags-area .reward-card").each(function() {
        var $this = $(this);
        var uploader = new window.R.Uploader($this.find("form"), addRewardImage.bind($this));
      });

    }.bind(this));
  };

  Company.prototype.bindRewardManagerAutocomplete = function() {
    $(".reward-manager-select").select2({
      ajax: {
        url: "/coworkers",
        dataType: 'json',
        delay: 250,
        data: function(params) {
          return {
            term: params.term, // search term
            page: params.page,
            include_self: true
          };
        },
        processResults: function(data, page) {
          return {
            results: data
          };
        },
        cache: true
      },
      escapeMarkup: function(markup) {
        return markup;
      },
      minimumInputLength: 1,
      templateResult: formatUser,
      templateSelection: formatUserSelection
    });
  };

  Company.prototype.removeRewardCard = function(e) {
    e.preventDefault();
    e.stopPropagation();
    var $target = $(e.target);

    if ($target.attr('href') === "javascript://") {
      $target.parents('.reward-card').fadeOut();

    } else {
      swal(
        {
          title: "Are you sure?",
          text: "This will delete this reward.",
          type: "warning",
          showCancelButton: true,
          confirmButtonColor: "#DD6B55",
          confirmButtonText: "Yes, remove it!",
          closeOnConfirm: true
        }, function() {
          $.ajax({
            url: $target.siblings("form").attr('action'),
            method: "DELETE"
          });

        }
      )
    }
  };

  Company.prototype.addRewardCard = function(e) {
    var $target = $(e.target);
    var $form, uploader;

    $("#reward-tags-area").prepend($target.data('form'));

    $form = $("#reward-tags-area .reward-card:first form");

    this.bindRewardManagerAutocomplete();
    e.preventDefault();

    uploader = new window.R.Uploader($form, addRewardImage.bind($form));
  };

  Company.prototype.lockUnpaidCompanyAdmin = function() {
    this.$companyWrapper = $("#company-admin-content-wrapper");
    var $selects;

    $(".iOSCheckContainer").off('mousedown mousemove touchstart click');

    this.$companyWrapper.on('change mousedown touchstart', '.iOSCheckContainer', function(e) {
      promptToPay(e);
      return false;
    });

    this.$companyWrapper.on('click', 'a:not(.unlocked):not(#upgrade-link),button,input[type=submit]', function(e) {
      promptToPay(e);
      return false;
    });

    $("#company-admin-content-wrapper select").focus(function() {
      $(this).data('lastSelected', $(this).find('option:selected'));
    });

    $selects = $('#company-admin-content-wrapper select');
    $selects.change(function(e) {
      $(this).data('lastSelected').attr('selected', true);
      promptToPay(e);
      return false;
    });
  };

  Company.prototype.initGraphs = function() {
    var colors = [];
    var values = [];
    var labels = [];

    $("#piechart-wrapper .color").each(function() {
      colors.push($(this).data("color"));
    });

    if (window.R.company && window.R.company.dashboard && window.R.company.dashboard.values) {
      Raphael("piechart", 600, 650).pieChart(300, 220, 150, window.R.company.dashboard.values, window.R.company.dashboard.labels, "#fff", colors);
    }

    this.addResGauge();

  };

  Company.prototype.badgeNominationToggle = function() {
    var $this = $(this).find("input[type='checkbox']");
    var $sendingLimitSelect = $this.closest(".widget-box").find(".sending-limit-type-select");

    if ( $this.is(':checked') ) {
        $sendingLimitSelect.hide();
    } else {
        $sendingLimitSelect.show();
    }  
  };

  Company.prototype.addEvents = function() {
    this.pagelet = new window.R.Pagelet();
    
    $document.on("click", "#custom-badges .nomination-wrapper .iOSCheckContainer", this.badgeNominationToggle);

    $("#custom-badges-disabled-link").bind(R.touchEvent, function(e) {
      var $destination = $($(this).attr("href"));
      e.preventDefault();

      $("html, body").animate({
        scrollTop: $destination.offset().top - 100
      });
    });

    $document.trigger("drawer-close", function() {
      if (window.location.hash) {
        window.location.hash = "#custom_badges";
      }
    });

    $('a[data-toggle="tab"]').on('shown', function(e) {
      var href = $(e.target).attr("href");
      var $imgs;

      if (href === "#dashboard") {
        R.ui.graph();
      }

      if (href === "#accounts") {
        //this.setUserTable();
      } else if (href === "#custom_badges") {

        this.setupBadges($document);
        $imgs = $("#custom_badges .custom-badge-image");
        if ($imgs.first().attr("src") === "") {
          $imgs.each(function() {
            var $this = $(this);
            $this.attr("src", $this.data("img"));
            $this.attr("style", "");
          });
        }
      } else if (href === "#settings") {
        this.turnOnToggles();
        this.turnOnSelectInputs();

      }

      if (window.history && window.history.pushState) {
        history.pushState(null, null, e.target.hash);
      }

      $('html,body').scrollTop(0);

      if ($('#company-admin-content-wrapper.unpaid').length > 0) {
        this.lockUnpaidCompanyAdmin();
      }

      this.bindYearsOfServiceRoleEvents();

    }.bind(this));


    $document.on("ajax:success", '.new_reward', function(e, data) {
      var $this = $(this),
        $hiddenInput = $("<input type='hidden' name='_method' value='patch'>");

      if ($this.hasClass('new_reward')) {
        $this.attr("action", data.reward.url);
        $this.append($hiddenInput);
        $this.removeClass("new_reward").attr("id", "");
      }

      return successFeedback("Reward Saved", $this);
    });

    this.$pointValues = $("#point-values");

    this.$pointValues.bind("ajax:complete", updateUI);

    $window.bind("ajaxify:success:kioskUrlUpdated", function(evt, data) {
      var $kioskURL = $("#kiosk-url");
      $kioskURL.html(data.data.params.kiosk_url_partial);
      $kioskURL.closest("form").find(".error").remove();
    });

    this.$pointValues.bind("ajax:complete", function() {
      return successFeedback("Values Updated", this.$pointValues);
    }.bind(this));

    $document.on("ajax:success", '.edit_reward', function() {
      return successFeedback("Reward Updated", $(this))
    });

  };

  Company.prototype.setupBadges = function($parent) {
    // $parent is to scope the events
    // on page load, parent is $document
    // however, when a page is created, $parent will be wrapper of new badge
    // so we can re-add the events safely without doubling up on existing badges
    var inputs = ".achievement-wrapper input[type='checkbox']";
    var $inputs = $parent.find(inputs);

    $inputs.iOSCheckbox({
      onChange: function() {
        var $this = $(this.elem);
        var $parent = $this.closest(".badge-information-column");
        var $achievementOptions = $parent.find(".achievement-options");

        $parent.find(".badge-options").addClass("hidden");

        if ($this.prop('checked')) {
          $parent.find(".normal-options").addClass("hidden");
          $achievementOptions.removeClass("hidden");
        } else {
          $parent.find(".normal-options").removeClass("hidden");
          $achievementOptions.addClass("hidden");
        }
      }
    });

    $(".nomination-wrapper input[type='checkbox']").iOSCheckbox();

    new window.R.Select2(function() {
      $parent.find('.company-role-select').select2({
        tokenSeparators: [',', ' ']
      });
    });
  };

  Company.prototype.setUserTable = function() {
    var windowHeight = $(window).height();
    var tableOffset = this.$userTable.offset().top;
    if (windowHeight > 600) {
      this.$userTable.height(windowHeight - tableOffset - (parseInt(this.$userTable.css("padding")) * 2) - 4);
    }
  };

  Company.prototype.turnOnToggles = function() {
    var $input = $("#settings .on-off"), that = this;

    $input.iOSCheckbox({
      onChange: function() {
        var $target = $(this.elem), data = {};
        var checkedValue = this.elem.prop("checked") ? true : false;
        data[$target.data('setting')] = checkedValue;
        that.updateSettings(data);
      }
    });

  };

  Company.prototype.turnOnSelectInputs = function() {
    var $input = $("#reset-interval"), that = this;
    that.selectInputs = that.selectInputs || {};

    $input.focus(function() {
      var $target = $(this);

      that.selectInputs[$target.uniqueId()] = $target.val();
    });

    $input.change(function() {
      var $target = $(this), data = {};
      var value = $target.val();
      data[$target.data('setting')] = value;

      //////////////////////////////////////////////////
      //
      // FIXME: the condition to update the select setting
      //        in on all selects right now...
      //        However, there is only one select input, so this is ok
      //        for now....
      //        if another is added, we'll need to figure out a way to
      //        generalize the condition
      //
      //////////////////////////////////////////////////
      msg = "Changing the reset interval will reset all the point totals relative to the selected interval. This will take a few minutes to process.  Are you sure?";
      if (confirm(msg)) {
        that.updateSettings(data);
      } else {
        $target.val(that.selectInputs[$target.uniqueId()]);
      }
    });
  };

  Company.prototype.updateSettings = function(data) {
    var isResetInterval = "reset_interval" in data;
    $.ajax({
      url: getURL('/company/update_settings'),
      type: "POST",
      data: { settings: data },
      success: function() {
        if (isResetInterval) {
          updateUI();
        }
      }
    });
  };

  Company.prototype.bindYearsOfServiceRoleEvents = function() {
    $document.on('click', '.role_toggle', function(e) {
      var $this = $(this);

      $this.closest('form').submit();

    });
    $document.on('click', '#all_teams_box', function(e) {
      var $this = $(this);
      var teamToggles = $(".role_toggle_individual_team");
      if (this.checked) {
        teamToggles.prop('checked', true)

      }
      else {
        teamToggles.prop('checked', false)
      }
      $this.closest('form').submit();
    });
  };

  function updateUI() {
    var headerTarget = "#header #header-profile-wrapper";
    $.get(window.location + " headerTarget", function(data) {
      $(headerTarget).replaceWith($(data).find(headerTarget));
    });
  }

  function successFeedback(message, element) {
    var $existingButtons = element.find(".success-mention");
    $existingButtons.remove();
    var $successButton = $('<p class="success-mention success-text">' + message + '</p>');
    element.append($successButton);
    $successButton.fadeOut(4000);
  }

  function pleaseWait($containerElement) {
    var $waitDiv = $("<div>Please wait...</div>");
    $waitDiv.css({ position: 'absolute', top: 200, left: 200 })
    $containerElement.append($waitDiv);
  }

  Company.prototype.setupTopEmployeesTab = function() {
    $("#rank").on("pageletLoaded", function() {
      this.dateRange = new window.R.DateRange({ container: $("#rank") });
    }.bind(this));
  };

  return Company;

})();
