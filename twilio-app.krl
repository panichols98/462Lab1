ruleset twilio-app {
  meta {
    use module twilio-sdk alias sdk
      with
        aToken = meta:rulesetConfig{"aToken"}
        sid = meta:rulesetConfig{"sid"}

      shares lastResponse
  }
  global {
    sendText = function(to, sender, message) {
      sdk:sendText(to, sender, message)
    }

    lastResponse = function() {
      {}.put(ent:lastTimestamp,ent:lastResponse)
    }
  }
  rule sendText1 {
    select when person sendText
    pre {
      recipient = event:attrs{"to"}
      sender = event:attrs{"sender"}
      content = event:attrs{"message"}
    }
    sdk:sendText(recipient, sender, content) setting(response)
    fired {
      ent:lastResponse := response
      ent:lastTimestamp := time:now()
    }
  }

  rule messages {
    select when person messages
    pre {
      recipient = event:attrs{"to"}
      sender = event:attrs{"sender"}
      pages = event:attrs{"numResults"}
    }

    sdk:getMessages(recipient, sender, pages) setting(response)
    fired {
      ent:lastResponse := response
      ent:lastTimestamp := time:now()
    }
  }
}
