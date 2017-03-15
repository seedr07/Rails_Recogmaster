window.chatChat = window.chatChat || {};

window.chatChat.messages = {
  "default": {
    avatar: "/assets/pages/home-about/team/alex.jpg",
    name: "Alex Grande",
    body: "Do you have any questions? You can ask them here!"
  },

  "hiagain": {
    avatar: "/assets/pages/home-about/team/alex.jpg",
    name: "Alex Grande",
    body: "Hi again, let us know if we can help!"
  },
  "pages": {

    "/yammer-integration": {
      id: "2753040093",
      events: {
        pageView: {
          body: "Is your company using Yammer? Message us to learn about our Yammer integration."
        },

        dom: [],

        scroll: [{
          element: "#marketing-browser-extensions-info .table",
          body: "Recognize is inserted right into Yammer through our browser extensions. I'm happy to explain more.",
          timeout: 500
        }]
      }
    },
    "/": {
      id: "2749090286",
      events: {
        pageView: {
          body: "Are you interested in learning how we are different from other recognition platforms? Message us here."
        },

        dom: [{
          type: "click",
          element: "#demo-video-trigger",
          body: "How was the demo video? Do you want to see more?",
          timeout: 500
        }],

        scroll: [
          {
            element: "#yammer-section",
            body: "Recognize is seamlessly integrated into Yammer. Message us to learn more.",
            timeout: 500
          },
          {
            element: "#banner .content",
            body: "You can sign in for free to view the application. Message us to learn how other companies are using Recognize.",
            timeout: 500
          }]
      }
    },
    "/features": {
      id: "2749100330",
      events: {
        pageView: {
          body: "Do you have questions about the features?"
        },

        scroll: [
        {
          element: "#action",
          body: "After looking at all the features do you have any questions. Ask here."
        }]
      }
    },
    "/engagement": {
      id: "2764500252",
      events: {
        pageView: {
          body: "Are you looking to use Recognize to engage your staff?"
        },

        dom: [],

        scroll: [{
          element: "#yammer",
          body: "Are you interested in learning more about the Yammer integration?",
          timeout: 500
        },
        {
          element: "#kiosk-mode",
          body: "Do you have a flat screen tv in your office to display recognition?",
          timeout: 500
        }]
      }
    },
    "/analytics": {
      id: "2785140131",
      events: {
        pageView: {
          body: "Recognize now provides recognition data export in excel. What are your data export needs?"
        },

        dom: [],

        scroll: [{
          type: "mouseover",
          element: "#value-graph",
          body: "We show the value graph and more in the Company Admin. Do you want access?",
          timeout: 500
        },
        {
          type: "mouseover",
          element: "#res",
          body: "Does your company have metrics that shows employee engagement? Message us here to talk more",
          timeout: 500
        }]
      }
    },
    "/customizations": {
      id: "2751440205",
      events: {
        pageView: {
          body: "What elements of a recognition program are important to you? Message us here."
        },

        dom: [],

        scroll: [{
          element: "#white-label",
          body: "We manually customize Recognize to match your company\'s look and feel.",
          timeout: 500
        },
          {
            element: "#choose-values",
            body: "The most customizable aspect of Recognize is the badges. Let\'s talk about your needs in the badges.",
            timeout: 500
          },
          {
            element: "#right-type",
            body: "Many companies enjoy the special privileges Recognize provides. Request a demo to see more.",
            timeout: 500
          }]
      }
    },
    "/tour": {
      id: "2756470292",
      events: {
        pageView: {
          body: "What brought you to look at the Recognize Tour? You can message us here."
        },

        dom: [],

        scroll: [{
          element: "#point1-wrapper",
          body: "Customers love that they can send badges via email. Please request a demo.",
          timeout: 500
        },

        {
          element: "#point3-wrapper",
          body: "Recognition data allows us to build customized scheduled reports to admin's inbox.",
          timeout: 500
        },
        {
          element: "#point4-wrapper",
          body: "Recognize is a feature-complete recognition platform for enterprise.",
          timeout: 500
        },
        {
          element: "#point5-wrapper",
          body: "Having an automated employee recognition program saves time and promotes focus.",
          timeout: 500
        },
        {
          element: "#action",
          body: "If you have any questions about how Recognize works, message us to setup a demo!",
          timeout: 500
        }
        ]
      }
    }
  }
};