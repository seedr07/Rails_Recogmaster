module TestimonialHelper
  def testimonial_html(testimonial_index)
    testimonial = testimonials[testimonial_index].present? ? testimonials[testimonial_index] : testimonials.sample
    "<blockquote class='blockquote-testimonial'><img src='/assets/#{testimonial[:img]}' alt='#{testimonial[:title]} avatar' class='avatar-img'><div class='content balance-text'>&#8220;#{testimonial[:quote]}&#8221;</div><footer>#{testimonial[:title]}<br>#{testimonial[:company]}</footer></blockquote>".html_safe
  end

  def self.avatar_path(img)
    "testimonials/#{img}"
  end

  TESTIMONIALS = [{
                    quote: "We can reinforce our core values and behaviors, and even use custom badges to set goals for people.",
                    title: "Jay Friedman, COO",
                    company: "Goodway Group",
                    img: "/pages/home-casestudy/jay.png"
                  },
                  {
                    quote: "It’s been a great tool for us to decide the winner of our top employee of the month contest.",
                    title: "Juli Pettijohn, Marketing Editor",
                    company: "Goodway Group",
                    img: avatar_path("goodway.jpg")
                  },
                  {
                    quote: "The Recognizeapp admin interface and scoring system are easy to understand and pick up quickly.",
                    title: "Juli Pettijohn, Marketing Editor",
                    company: "Goodway Group",
                    img: avatar_path("goodway.jpg")
                  },
                  {
                    quote: "The tool has helped us improve our internal morale: We now can immediately congratulate employees on a job well done—and all in an entertaining and novel way.",
                    title: "Juli Pettijohn, Marketing Editor",
                    company: "Goodway Group",
                    img: avatar_path("goodway.jpg")
                  },
                  {
                    quote: "With Recognize, we were able to create our own badges that linked with our behavioral framework.",
                    title: "Bruce Rioch, Head of Business Intelligence",
                    company: "Metro Bank",
                    img: avatar_path("bruce.jpg")
                  },
                  {
                    quote: "We have a customer ethos to “surprise and delight” and we encourage colleagues to tell stories on yammer about what happened / how they surprised and delighted customers... we wanted to create a recognition scheme around this... Hence Recognize.",
                    title: "Bruce Rioch, Head of Business Intelligence",
                    company: "Metro Bank",
                    img: avatar_path("bruce.jpg")
                  },
                  {
                    quote: "This is definitely a really simple solution to implement and carries so much momentum if followed through by everyone (incl Execs!)",
                    title: "Bruce Rioch, Head of Business Intelligence",
                    company: "Metro Bank",
                    img: avatar_path("bruce.jpg")
                  },
                  {
                    quote: "It has definitely helped focus and motivate our teams active in Recognize.",
                    title: "Tessa Hammond, Director of Clinical Operations",
                    company: "American Medical Technologies",
                    img: avatar_path("tessa.jpg")
                  },
                  {
                    quote: "Enterprise Social is changing the way we interact with our customers and within our companies... RecognizeApp and its Yammer integration is an answer to this challenge.",
                    title: "Carlos de Huerta Mezquita, Solution Architect",
                    company: "Microsoft",
                    img: avatar_path("carlos.png")
                  },
                  {
                    quote: "As far as Enterprise recognition apps go Recognize is one of the best designed it is simple and effective, we love it.",
                    title: "Nat Salvione, VP Business Development",
                    company: "Tango Card",
                    img: avatar_path("nat.jpg")
                  },

                  {
                    quote: "At our annual celebration we prized our employees based on the recognizeapp ranking.",
                    title: "Leonardo Nogueira, CEO",
                    company: "Prosperi",
                    img: avatar_path("leonardo.jpg")
                  }]
  def testimonials
    TESTIMONIALS
  end
end