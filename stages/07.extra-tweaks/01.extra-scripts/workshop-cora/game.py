import time
from pynput.keyboard import Key, Controller
import adi

keyboard = Controller()

my_acc = adi.adxl355(uri="local:")

# Get data for X and Y axes and compute them
def get_accel_data():
    x = int(my_acc.accel_x.raw * my_acc.accel_x.scale)
    y = int(my_acc.accel_y.raw * my_acc.accel_y.scale)
    return x, y

# Map accelerometer data to direction
# 'Up' and 'Left' are interchanged to fit the CoraZ7 standard position
# 'Down' and 'Right' are interchanged to fit the CoraZ7 standard position
def map_accel_to_direction(x, y, threshold=7):
    if x > threshold:
        return 'left'
    elif x < -threshold:
        return 'right'
    elif y > threshold:
        return 'down'
    elif y < -threshold:
        return 'up'
    return None

# Read accelerometer data and pres corresponding key
try:
    while True:
        x, y = get_accel_data()
        direction = map_accel_to_direction(x, y)

        if direction:
            if direction == 'up':
                keyboard.press(Key.up)
                keyboard.release(Key.up)
            elif direction == 'down':
                keyboard.press(Key.down)
                keyboard.release(Key.down)
            elif direction == 'left':
                keyboard.press(Key.left)
                keyboard.release(Key.left)
            elif direction == 'right':
                keyboard.press(Key.right)
                keyboard.release(Key.right)

        time.sleep(0.1)

except KeyboardInterrupt:
    print("Exiting...")
