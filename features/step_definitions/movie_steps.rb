# Add a declarative step here for populating the DB with movies.
require 'date'

Given(/^the following movies exist:$/) do |movies_table|
  movies_table.hashes.each do |row|
    Movie.create!(
      title:        row['title'],
      rating:       row['rating'],
      release_date: row['release_date'] && Date.parse(row['release_date'])
    )
  end
end

Then(/^(.*) seed movies should exist$/) do |n_seeds|
  expect(Movie.count).to eq n_seeds.to_i
end


# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then(/^I should see "(.*)" before "(.*)"(?: in the movie list)?$/) do |e1, e2|
  body = page.body
  expect(body).to include(e1), "Expected to find #{e1.inspect} on the page"
  expect(body).to include(e2), "Expected to find #{e2.inspect} on the page"
  expect(body.index(e1)).to be < body.index(e2)
end


# Make it easier to express checking or unchecking several boxes at once
#  "When I check only the following ratings: PG, G, R"

When(/^I (un)?check the following ratings: (.*)$/) do |un, rating_list|
  rating_list.split(/\s*,\s*/).each do |rating|
    if un
      uncheck(rating, allow_label_click: true)
    else
      check(rating, allow_label_click: true)
    end
  end
end


Then(/^I should (not )?see the following movies: (.*)$/) do |no, movie_list|
  # Take a look at web_steps.rb Then /^(?:|I )should see "([^"]*)"$/
  titles = movie_list.split(/\s*,\s*/)
  if no
    titles.each { |t| expect(page).not_to have_content(t) }
  else
    titles.each { |t| expect(page).to have_content(t) }
  end
end

Then(/^I should see all the movies$/) do
  # Make sure that all the movies in the app are visible in the table
  Movie.pluck(:title).each { |t| expect(page).to have_content(t) }
end

### Utility Steps Just for this assignment.

Then(/^debug$/) do
  # Use this to write "Then debug" in your scenario to open a console.
  require "byebug"
  byebug
  1 # intentionally force debugger context in this method
end

Then(/^debug javascript$/) do
  # Use this to write "Then debug" in your scenario to open a JS console
  page.driver.debugger
  1
end

Then(/complete the rest of of this scenario/) do
  # This shows you what a basic cucumber scenario looks like.
  # You should leave this block inside movie_steps, but replace
  # the line in your scenarios with the appropriate steps.
  raise "Remove this step from your .feature files"
end

When(/^I submit the ratings form$/) do
  click_button 'Refresh'
end

Then(/^I should see movies with ratings: (.*)$/) do |rating_list|
  rating_list.split(/\s*,\s*/).each do |rating|
    expect(page).to have_text("Rating: #{rating}")
  end
end

Then(/^I should not see movies with ratings: (.*)$/) do |rating_list|
  rating_list.split(/\s*,\s*/).each do |rating|
    expect(page).not_to have_text("Rating: #{rating}")
  end
end
