require 'spec_helper'

describe 'Selecting Students', type: :feature do

  before(:all) do
    Capybara.javascript_driver = :selenium
    set_resource 'student'
  end

  let!(:preset) { create(:preset, chooser_fields: {show_name: '1', show_surname: '1'}) }

  let(:enrollment_status_admitted) { create(:enrollment_status_admitted) }
  let(:student) { create(:student, name: 'John', surname: 'Doe', enrollment_status_code: enrollment_status_admitted.code) }
  let(:student2) { create(:student, name: 'Susumu', surname: 'Yokota', enrollment_status_code: enrollment_status_admitted.code) }

  before do
    as :admin
  end

  context 'existing' do
    before do
      enrollment_status_admitted
      student
      student2
      visit gaku.students_path
    end

    it 'saves the selection', js: true do
      find(:css, "input#student-#{student.id}").set(true)
      find(:css, "input#student-#{student2.id}").set(true)
      page.has_selector? '#students-checked-div'
      page.has_content? 'Chosen students(2)'

      visit gaku.root_path
      visit gaku.students_path

      find(:css, "input#student-#{student.id}").should be_checked
      find(:css, "input#student-#{student2.id}").should be_checked
      page.has_selector? '#students-checked-div'
      page.has_content? 'Chosen students(2)'
    end

    it 'unchecks preselected students', js: true do
      find(:css, "input#student-#{student.id}").set(true)
      find(:css, "input#student-#{student2.id}").set(true)
      page.has_selector? '#students-checked-div'
      page.has_content? 'Chosen students(2)'

      visit gaku.root_path
      visit gaku.students_path

      find(:css, "input#student-#{student.id}").should be_checked
      find(:css, "input#student-#{student2.id}").should be_checked
      find(:css, "input#student-#{student.id}").set(false)

      find(:css, "input#student-#{student.id}").should_not be_checked
      page.has_selector? '#students-checked-div'
      expect(page.has_content?('Chosen students(1)')).to eq true
    end

    it 'clears preselected students', js: true do
      find(:css, "input#student-#{student.id}").set(true)
      find(:css, "input#student-#{student2.id}").set(true)
      page.has_selector? '#students-checked-div'
      page.has_content? 'Chosen students(2)'

      visit gaku.root_path
      visit gaku.students_path

      find(:css, "input#student-#{student.id}").should be_checked
      find(:css, "input#student-#{student2.id}").should be_checked
      find(:css, "#clear-student-selection").click

      find(:css, "input#student-#{student.id}").should_not be_checked
      find(:css, "input#student-#{student2.id}").should_not be_checked
      !page.has_selector? '#students-checked-div'
      expect(page.has_content?('Chosen students(1)')).to eq false
    end

    it 'removes selected student', js: true do
      find(:css, "input#student-#{student.id}").set(true)
      page.has_selector? '#students-checked-div'
      page.has_content? 'Chosen students(1)'
      click_link 'Show'
      find(:css, ".remove-student").click
      find(:css, "input#student-#{student.id}").should_not be_checked
      page.has_content? 'Chosen students(1)'

      visit gaku.root_path
      visit gaku.students_path

      find(:css, "input#student-#{student.id}").should_not be_checked

      !page.has_selector? '#students-checked-div'
      expect(page.has_content?('Chosen students(1)')).to eq false
    end

  end

end