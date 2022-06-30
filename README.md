# Symbl iOS Demo

An iOS app with Symbl realtime api integration

## How to run?

Go to file Shared/RecordingView.swift

```swift
    // Replace accessToken & uniqueMeetinId below variables with appropriate data

    struct RecordingView: View {
    ...

    .onAppear {
        let accessToken = "CHANGE_THIS"
        let uniqueMeetingId = "subodh.jena@symbl.ai".toBase64()

        symbl = Symbl(accessToken: accessToken)

        symbl.initializeRealtimeSession(meetingId: uniqueMeetingId, delegate: symblRealtimeDelegate)
        symbl.realtimeSession?.connect()
    }
```
