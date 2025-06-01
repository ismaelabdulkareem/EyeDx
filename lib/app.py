from flask import Flask, request, jsonify, send_file
import cv2
import numpy as np
import io

app = Flask(__name__)

def crop_and_preprocess_fundus(image, target_size=(224, 224)):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    gray_blurred = cv2.medianBlur(gray, 15)

    circles = cv2.HoughCircles(
        gray_blurred,
        cv2.HOUGH_GRADIENT,
        dp=1,
        minDist=1000,
        param1=50,
        param2=30,
        minRadius=100,
        maxRadius=1000
    )

    if circles is None:
        return None

    circles = np.uint16(np.around(circles))
    x, y, r = circles[0][0]
    x, y, r = int(x), int(y), int(r)

    mask = np.zeros_like(gray)
    cv2.circle(mask, (x, y), r, 255, thickness=-1)
    masked_img = cv2.bitwise_and(image, image, mask=mask)

    height, width = image.shape[:2]
    x1 = max(x - r, 0)
    x2 = min(x + r, width)
    y1 = max(y - r, 0)
    y2 = min(y + r, height)

    cropped_img = masked_img[y1:y2, x1:x2]
    if cropped_img.size == 0:
        return None

    resized_img = cv2.resize(cropped_img, target_size, interpolation=cv2.INTER_AREA)

    # Normalize pixel values to 0-1 float
    normalized_img = resized_img.astype(np.float32) / 255.0

    # Convert back to uint8 for sending as JPEG (scale back to 0-255)
    send_img = (normalized_img * 255).astype(np.uint8)

    return send_img


@app.route('/crop', methods=['POST'])
def crop():
    if 'image' not in request.files:
        return jsonify({'error': 'No image part'}), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    file_bytes = np.frombuffer(file.read(), np.uint8)
    image = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)

    processed = crop_and_preprocess_fundus(image)
    if processed is None:
        return jsonify({'error': 'No circle detected or invalid crop'}), 400

    _, buffer = cv2.imencode('.jpg', processed)
    io_buf = io.BytesIO(buffer)

    return send_file(io_buf, mimetype='image/jpeg')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=47356, debug=True)





