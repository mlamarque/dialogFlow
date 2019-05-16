class DialogFlow

  def initialize(params)
    @credentials = ActiveSupport::JSON.decode(params[:credential])
    @project_id = params[:project_id]
    @intents_client = Google::Cloud::Dialogflow::Intents.new(credentials: @credentials)
  end

  def detect(text)
    @sessions_client = Google::Cloud::Dialogflow::V2::Sessions.new(credentials: @credentials)
    formatted_session = Google::Cloud::Dialogflow::V2::SessionsClient.session_path(@project_id, "[SESSION]")
    query_input = { text: { text: text, language_code: "fr" } }
    response = @sessions_client.detect_intent(formatted_session, query_input)
    {
      question: response['query_result']['query_text'],
      answer: response['query_result']['fulfillment_text'],
      score: response['query_result']['intent_detection_confidence'],
      intent: response['query_result']['intent'].try('display_name'),
    }
  end

  def get_intents
   parent = @intents_client.class.project_agent_path(@project_id)
   _intents = []
   @intents_client.list_intents(parent).each do |i|
     _intents << {id: /projects\/#{@project_id}\/agent\/intents\/(.*)/.match(i.name)[1], name: i.display_name}
   end
   _intents.sort_by{ |intent| intent[:name].downcase }
  end

  def get_intent(iid:)
    response = @intents_client.get_intent("projects/#{@project_id}/agent/intents/#{iid}", language_code: 'fr', intent_view: "INTENT_VIEW_FULL")
    ap response
    
    {
      id: /projects\/#{@project_id}\/agent\/intents\/(.*)/.match(response.name)[1],
      name: response.display_name,
      responses: response.messages.map { |resp| resp.try(:text)&.try(:text) },
      questions: response.training_phrases.map { |resp| {text: resp.try(:parts).map(&:text).join(""), id: resp.try(:name)} },
    }
  end

  def delete_intent(iid:)
    response = @intents_client.delete_intent("projects/#{@project_id}/agent/intents/#{iid}")
    {:status=>{:code=>200, :errorType=>"success"}}
  end

  def create_intent(options) # {name: "", answer: "", utterances: [""]}
    begin
      _utterances = []
      options[:utterances].each do |_utterance| 
        _utterances << Google::Cloud::Dialogflow::V2::Intent::TrainingPhrase.new( type: :EXAMPLE, parts: [Google::Cloud::Dialogflow::V2::Intent::TrainingPhrase::Part.new(text: _utterance)])
      end
      _messages = [Google::Cloud::Dialogflow::V2::Intent::Message.new(text: Google::Cloud::Dialogflow::V2::Intent::Message::Text.new(text: [options[:answer]]))]
      response = @intents_client.create_intent("projects/#{@project_id}/agent", {display_name: options[:name], training_phrases: _utterances, messages: _messages})
    rescue Exception => e
      { message: e }
    end
    
  end
end
