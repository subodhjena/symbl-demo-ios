# Symbl iOS Demo

An iOS app with Symbl realtime api integration

## How to run?

Go to file Shared/RecordingView.swift

```swift
    // Replace accessToken & uniqueMeetinId below variables with appropriate data
    
    struct RecordingView: View {
        let accessToken = "CHANGE_THIS"
    
        private var _memo: Memo
        var memo: Memo {
            get { return _memo }
        }
        
    ...
    
    .onAppear {
        symbl = Symbl(accessToken: accessToken)

        let uniqueMeetingId = "subodh.jena@symbl.ai".toBase64()
        symbl!.initializeRealtimeSession(meetingId: uniqueMeetingId, delegate: symblRealtimeDelegate)
        symbl!.realtimeSession?.connect()
    }
```
