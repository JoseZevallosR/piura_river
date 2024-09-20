import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# Cross-section coordinates (x and z values)
data = {
    'x': [0, 1.077696746, 2.155393492, 3.233090237, 4.310786983, 5.388483729, 6.466180475, 7.543877221, 
          8.621573967, 9.699270712, 10.77696746, 11.8546642, 12.93236095, 14.0100577, 15.08775444, 
          16.16545119, 17.24314793, 18.32084468, 19.39854142, 20.47623817, 21.55393492, 22.63163166, 
          23.70932841, 24.78702515, 25.8647219, 26.94241865, 28.02011539, 29.09781214],
    'z': [552.0439453, 551.8529053, 551.6530151, 551.4296265, 550.9699707, 550.6017456, 549.9367065, 
          549.4327393, 548.9751587, 548.468811, 548.2611084, 548.1293945, 548.0340576, 548.0276489, 
          548.0790405, 548.1238403, 548.1762085, 548.3883057, 548.5161743, 548.6787109, 549.1192017, 
          549.4696655, 550.3006592, 550.848877, 551.4048462, 552.2157593, 552.5487671, 552.7687378]
}

# Convert data to numpy arrays
x = np.array(data['x'])
z = np.array(data['z'])

# Water levels to animate
water_levels = [548.5, 549.0, 549.5, 550.0]

# Create the figure and axis
fig, ax = plt.subplots(figsize=(10, 5))

# Function to update the plot
def update(frame):
    ax.clear()
    
    # Plot the cross-section profile (channel bed)
    ax.plot(x, z, 'k-', linewidth=2, label='Channel Bed')
    
    # Fill the area under the water level with cyan to represent water
    ax.fill_between(x, z, frame, where=(z < frame), color='cyan', label='Water', interpolate=True)
    
    # Fill the area below the channel bed to represent the riverbed
    ax.fill_between(x, z, np.min(z) - 1, color='gray', label='Riverbed')
    
    # Labels and title
    ax.set_xlabel('Along-Transect Distance (m)')
    ax.set_ylabel('Elevation (m)')
    ax.set_title(f'Channel Cross-Section with Water Level = {frame} m')
    
    # Set the plot limits
    ax.set_xlim([np.min(x), np.max(x)])
    ax.set_ylim([np.min(z) - 1, np.max(z) + 1])
    
    # Add legend
    ax.legend()

# Create the animation
ani = FuncAnimation(fig, update, frames=water_levels, repeat=True, interval=1000)

plt.show()

