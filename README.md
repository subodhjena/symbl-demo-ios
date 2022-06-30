# Symbl iOS SDK Demo

A simple memo iOS app which uses symbl's realtime iOS sdk to get insights from live voice recording

`Note: The demo requries a real device to work`

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

## How to see output?

There is some work that needs to be done on the UI. For now, You can look at the logs for the actual responses. Please look for the `SymblRealtimeDataDelegate` implementation
