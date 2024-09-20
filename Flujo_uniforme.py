import numpy as np
import pandas as pd
from scipy.integrate import quad

# Your data points for x and z
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
    'z': [],
    'area': [],
    'perimeter': [],
    'flow': []
}

# Perform calculations for each row
for i in range(rows + 1):
    z_value = func(x_min + i * delta_x)
    tabla['z'].append(z_value)
    
    x_start = x_min - i * delta_x
    x_end = x_min + i * delta_x
    
    # Perimeter (arc length)
    length, _ = quad(arc_length_integrand, x_start, x_end)
    tabla['perimeter'].append(length)
    
    # Area calculation
    area, _ = quad(func, x_start, x_end)
    z_end = func(x_end)
    area_h = z_end * (x_end - x_start) - area
    tabla['area'].append(area_h)

    # Manning equation
    if length == 0:
        tabla['flow'].append(0)
    else:
        tabla['flow'].append(area_h**(5/3)*s**0.5/(n*length**(2/3)))
    

# Create a DataFrame to display the table
df = pd.DataFrame(tabla)
print(df)
