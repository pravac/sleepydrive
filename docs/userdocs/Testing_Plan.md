# Testing Scenarios

The following tests verify that the driver monitoring system behaves correctly under various conditions. Each test defines what should happen and when it should occur.

| Test Case | When It Happens | Expected Behavior |
|-----------|----------------|------------------|
| User Not Visible | The driver moves out of the camera’s field of view or their face cannot be detected with the camera. | The system detects that the driver is no longer visible and issues a warning such as "Driver not detected." The model needs to detect correctly and the phone needs to give a notification. |
| Camera Moved or Misaligned | The camera position or angle changes and the driver's face can no longer be properly tracked. | The system prompts the user to adjust or recalibrate the camera before monitoring resumes. |
| Not Connected to Jetson | The mobile app attempts to communicate with the Jetson device but the connection fails. | The app displays a "Device Not Connected" warning and prevents monitoring from starting until the connection is restored. |
| Calibration Not Completed | A new user starts the system or calibration data is missing. | The system requires the user to complete the calibration process before monitoring begins. |
| Driver About to Fall or Completely Asleep | The AI detects prolonged eye closure, head drooping, or other indicators that the driver is asleep. | A high-priority alert such as a loud sound or vibration is triggered. The driver is prompted to wake up or pull over. |
| Driver Slight Drowsy | Early fatigue indicators such as slow blinking, long eye closure, or head nodding are detected. | The system sends a warning alert encouraging the driver to stay attentive or take a break. |
| App Works Without Network | The system loses internet connectivity while monitoring is active. | Real-time driver monitoring and alerts continue locally. Data may be stored and synced when connectivity returns. |
| Spoofing with Incorrect Camera Feed | An incorrect or external video source is connected instead of the intended driver camera. | The system detects the invalid feed and disables monitoring until a verified camera input is restored. |

<div style="page-break-after: always;"></div>
