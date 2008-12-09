require File.dirname(__FILE__) + '/../spec_helper'

describe Question, 'associations' do
  it 'should belong to a journal' do
    Question.should have_association(:journal, :belongs_to)
  end

  it 'should belong to an author' do
    Question.should have_association(:author, :belongs_to)
  end

  it 'should belong to an assigned user' do
    Question.should have_association(:assigned_to, :belongs_to)
  end

  it 'should belong to an issue' do
    Question.should have_association(:issue, :belongs_to)
  end
  
end

describe Question, 'requires' do
  include QuestionSpecHelper
  
  it 'a journal' do
    question = question_factory(1)
    user = mock_model(User)
    question.stub!(:author).and_return(user)
    assignee = mock_model(User)
    question.stub!(:assigned_to).and_return(assignee)
    issue = mock_model(Issue)
    question.stub!(:issue).and_return(issue)
    
    question.should_not be_valid
    question.errors.on(:journal).should include("activerecord_error_blank")
  end

  it 'an author' do
    question = question_factory(1)
    journal = mock_model(Journal)
    question.stub!(:journal).and_return(journal)
    assignee = mock_model(User)
    question.stub!(:assigned_to).and_return(assignee)
    issue = mock_model(Issue)
    question.stub!(:issue).and_return(issue)
    
    question.should_not be_valid
    question.errors.on(:author).should include("activerecord_error_blank")
  end

  it 'an issue' do
    question = question_factory(1)
    user = mock_model(User)
    question.stub!(:author).and_return(user)
    journal = mock_model(Journal)
    question.stub!(:journal).and_return(journal)
    assignee = mock_model(User)
    question.stub!(:assigned_to).and_return(assignee)
    
    question.should_not be_valid
    question.errors.on(:issue).should include("activerecord_error_blank")
    
  end
  
end

describe Question,"#formatted_list with no questions" do
  it 'should return an empty string' do
    Question.formatted_list([]).should eql('')
  end
end

describe QuestionIssuePatch,"#formatted_list with one question" do
  before(:each) do
    @content = 'This is a journal note that is supposed to have the question content in it but only up the 120th character, but does it really work?'
    @journal = mock_model(Journal, :notes => @content)
    @question = mock_model(Question, :journal => @journal)
    @questions = [@question]
  end
  
  it 'should not be blank' do
    Question.formatted_list(@questions).should_not be_blank
  end
  
  it 'should return the first 120 characters of the question' do
    question_content = Question.formatted_list(@questions)
    question_content.should_not match(/really work/)
    question_content.should match(/This is a journal note/)
  end
  
  it 'should have ellipses if when over 120 characters of content' do
    Question.formatted_list(@questions).should match(/\.\.\./)
  end

  it 'should not have ellipses when there are under 120 characters of content' do
    content = 'Short question'
    journal = mock_model(Journal, :notes => content)
    question = mock_model(Question, :journal => journal)
    questions = [question]
    
    Question.formatted_list(questions).should_not match(/\.\.\./)
  end

end

describe QuestionIssuePatch,"#formatted_questions with multiple questions" do
  before(:each) do
    @content_one = 'This is a journal note that is supposed to have the question content in it but only up the 120th character, but does it really work?'
    @journal_one = mock_model(Journal, :notes => @content_one)
    @content_two = 'Another journal with a unique content that is well over 120 characters but it will be ok becasue it is truncated soon.  Maybe.'
    @journal_two = mock_model(Journal, :notes => @content_two)
    
    
    @question = mock_model(Question, :journal => @journal_one)
    @question_two = mock_model(Question, :journal => @journal_two)
    @questions = [@question, @question_two]
  end
  
  it 'should not be blank' do
    Question.formatted_list(@questions).should_not be_blank
  end
  
  it 'should return the first 120 characters of each question' do
    question_content = Question.formatted_list(@questions)
    question_content.should_not match(/really work/)
    question_content.should match(/This is a journal note/)
    
    question_content.should_not match(/maybe/i)
    question_content.should match(/unique/)
    
  end
  
  it 'should separate each question with a line break' do
    questions = Question.formatted_list(@questions).split('\n')
    questions.should have(2).things
  end
end
