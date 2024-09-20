import numpy as np
import pandas as pd
from scipy.integrate import quad

# Your data points for x and z
data = pd.read_csv('cross.csv',sep=';')

# Create interpolation functions for z(x) and its derivative
x_data = np.array(data['x'])
z_data = np.array(data['z'])

# Linear interpolation for z(x)
def func(x):
    return np.interp(x, x_data, z_data)

# Numerical derivative of the interpolated function (using finite differences)
def derivative(x, delta=1e-5):
    return (func(x + delta) - func(x)) / delta

# Arc length integrand using the derivative
def arc_length_integrand(x):
    return np.sqrt(1 + derivative(x)**2)

# Set up variables for area and perimeter calculations
x_min = 29 / 2
delta_x = 0.5
rows = int(29 / (delta_x*2))
n = 0.03
s = 0.02741

# Initialize table to store results
tabla = {
    'z (m)': [],
    'area (m2)': [],
    'perimeter (m)': [],
    'velocity (m/s)' : [],
    'flow (m3/s)': []
}

# Perform calculations for each row
for i in range(rows + 1):
    z_value = func(x_min + i * delta_x)
    tabla['z (m)'].append(z_value)
    
    x_start = x_min - i * delta_x
    x_end = x_min + i * delta_x
    
    # Perimeter (arc length)
    length, _ = quad(arc_length_integrand, x_start, x_end)
    tabla['perimeter (m)'].append(length)
    
    # Area calculation
    area, _ = quad(func, x_start, x_end)
    z_end = func(x_end)
    area_h = z_end * (x_end - x_start) - area
    tabla['area (m2)'].append(area_h)

    # Manning equation
    if length == 0:
        tabla['flow (m3/s)'].append(0)
        tabla['velocity (m/s)'].append(0)
    else:
        tabla['velocity (m/s)'].append(area_h**(2/3)*s**0.5/(n*length**(2/3)))
        tabla['flow (m3/s)'].append(area_h**(5/3)*s**0.5/(n*length**(2/3)))
    

# Create a DataFrame to display the table
df = pd.DataFrame(tabla)
print(df)
