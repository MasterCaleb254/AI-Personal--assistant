// VoiceChannel.java
public class VoiceChannel {
  private static final String CHANNEL = "ai.assistant/voice";
  private MediaRecorder mediaRecorder;
  private MediaPlayer mediaPlayer;
  private String currentFilePath;
  
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
    final VoiceChannel instance = new VoiceChannel(registrar.context());
    channel.setMethodCallHandler(instance);
  }

  private VoiceChannel(Context context) {
    // Initialize resources
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "startRecording":
        try {
          String filePath = startRecording();
          result.success(filePath);
        } catch (Exception e) {
          result.error("RECORD_ERROR", e.getMessage(), null);
        }
        break;
        
      case "stopRecording":
        stopRecording();
        result.success(null);
        break;
        
      case "playAudio":
        String path = call.argument("filePath");
        playAudio(path);
        result.success(null);
        break;
        
      // Other methods...
        
      default:
        result.notImplemented();
    }
  }
  
  private String startRecording() throws IOException {
    String fileName = "recording_" + System.currentTimeMillis() + ".aac";
    File outputFile = new File(getExternalCacheDir(), fileName);
    
    mediaRecorder = new MediaRecorder();
    mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
    mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.AAC_ADTS);
    mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
    mediaRecorder.setOutputFile(outputFile.getAbsolutePath());
    
    mediaRecorder.prepare();
    mediaRecorder.start();
    
    return outputFile.getAbsolutePath();
  }
}