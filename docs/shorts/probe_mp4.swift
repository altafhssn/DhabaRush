// Checks a finished Short with Apple AVFoundation (docs/shorts/README.md).
//   swiftc -O docs/shorts/probe_mp4.swift -o /tmp/probe_mp4
//   /tmp/probe_mp4 clip.mp4 [seconds out.jpg]   -> JSON: length, size, fps, codec, audio; optional decoded frame
import AVFoundation
import Foundation
let url = URL(fileURLWithPath: CommandLine.arguments[1])
let asset = AVURLAsset(url: url)
let sem = DispatchSemaphore(value: 0)
Task {
  do {
    let dur = try await asset.load(.duration)
    var out: [String: Any] = ["seconds": CMTimeGetSeconds(dur)]
    for t in try await asset.loadTracks(withMediaType: .video) {
      let sz = try await t.load(.naturalSize)
      let fr = try await t.load(.nominalFrameRate)
      let fd = try await t.load(.formatDescriptions)
      out["video"] = ["w": sz.width, "h": sz.height, "fps": fr, "codec": fd.map { String(describing: CMFormatDescriptionGetMediaSubType($0)) }]
    }
    for t in try await asset.loadTracks(withMediaType: .audio) {
      let fd = try await t.load(.formatDescriptions)
      let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fd[0])!.pointee
      out["audio"] = ["sr": asbd.mSampleRate, "ch": asbd.mChannelsPerFrame]
    }
    if CommandLine.arguments.count > 3 {
      let gen = AVAssetImageGenerator(asset: asset)
      gen.requestedTimeToleranceBefore = .zero; gen.requestedTimeToleranceAfter = .zero
      let t = CMTime(seconds: Double(CommandLine.arguments[2])!, preferredTimescale: 600)
      let (img, _) = try await gen.image(at: t)
      let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: CommandLine.arguments[3]) as CFURL, "public.jpeg" as CFString, 1, nil)!
      CGImageDestinationAddImage(dest, img, nil); CGImageDestinationFinalize(dest)
      out["frame"] = CommandLine.arguments[3]
    }
    let d = try JSONSerialization.data(withJSONObject: out)
    print(String(data: d, encoding: .utf8)!)
  } catch { print("ERR \(error)") }
  sem.signal()
}
sem.wait()
