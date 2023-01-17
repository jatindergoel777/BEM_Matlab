function airOut = airProp(air)
AirData = importdata('AirDensityViscosity.xlsx');
if isempty(air.h) && ~isempty(air.Tinf)
    dv = AirData.data.Sheet1(:,2).*10^(-6); %Ns/m2
    kv = AirData.data.Sheet1(:,3).*10^(-6); %m2/s
    rho = AirData.data.Sheet1(:,4);
    if strcmp(air.Tunit,'K')
        T = AirData.data.Sheet1(:,1)+273.15;
    elseif strcmp(air.Tunit,'C')
        T = AirData.data.Sheet1(:,1);
    else
        error('Error. Please input temperature units: K - Kelvin (K) or C- Celsius.')
    end

    airOut.rho = interp1(T,rho,air.Tinf,'spline');
    airOut.mu = interp1(T,dv,air.Tinf,'spline');
    airOut.nu = interp1(T,kv,air.Tinf,'spline');
    airOut.T = air.Tinf;
elseif ~isempty(air.h) && isempty(air.Tinf)
    h = AirData.data.Sheet2(:,1); %m
    rho = AirData.data.Sheet2(:,5); %kg/m3
    dv = AirData.data.Sheet2(:,6).*10^(-5); %Ns/m2
    if strcmp(air.Tunit,'K')
        T = AirData.data.Sheet2(:,2)+273.15;
    elseif strcmp(air.Tunit,'C')
        T = AirData.data.Sheet2(:,2);
    else
        error('Error. Please input temperature units: K - Kelvin (K) or C- Celsius.')
    end
    airOut.rho = interp1(h,rho,air.h,'spline');
    airOut.mu = interp1(h,dv,air.h,'spline');
    airOut.nu = airOut.mu./airOut.rho;
    airOut.T = interp1(h,T,air.h,'spline');
    airOut.h = air.h;
end
    