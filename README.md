# DialogFlow API V2 Wrapper


# Methods

## Init
wrapper = DialogFlow.new({project_id: "...", credentials: "{json...}"})
## Detect text
wrapper.detect("Hello")
## Get Intents
wrapper.get_intents
## Get Intent from Id
wrapper.get_intent("12345678")
## Create Intent from parameters
wrapper.create_intent({name: "", answer: "", utterances: [""]})
## delete Intent from id
wrapper.delete_intent("12345678")
