function air = airProp(airT,unit)
AirData = importdata('AirDensityViscosity.xlsx');
dv = AirData.data(:,2).*10^(-6); %Ns/m2
kv = AirData.data(:,3).*10^(-6); %m2/s
rho = AirData.data(:,4);
if strcmp(unit,'K')
    T = AirData.data(:,1)+273.15;
elseif strcmp(unit,'C')
    T = AirData.data(:,1);
else
    error('Error. Please input temperature units: K - Kelvin (K) or C- Celsius.')
end

air.rho = interp1(T,rho,airT,'spline');
air.mu = interp1(T,dv,airT,'spline');
air.nu = interp1(T,kv,airT,'spline');
    
    