from flask import Flask, Response
import cv2

app = Flask(__name__)

# Define the RTSP URLs
rtsp_url_1 = 'rtsp://192.168.1.21/live/ch00_0'
rtsp_url_2 = 'rtsp://192.168.1.21/live/ch00_0'

# Function to generate frames, with rtsp_url as an argument
def generate_frames(rtsp_url):
    cap = cv2.VideoCapture(rtsp_url)
    cap.set(cv2.CAP_PROP_BUFFERSIZE, 2)  # Reduce buffer size for lower latency
    while True:
        success, frame = cap.read()
        if not success:
            break
        else:
            # Encode the frame in JPEG format
            frame = cv2.resize(frame, (640,360)) # Adjust resolution if needed
            _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 70])
            frame = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
    cap.release()

@app.route('/video_feed_1')
def video_feed_1():
    return Response(generate_frames(rtsp_url_1), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/video_feed_2')
def video_feed_2():
    return Response(generate_frames(rtsp_url_2), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)  # Accessible from any network interface
