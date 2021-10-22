program main
    implicit none

    real(8) :: A, B, Tg, Tr, dh, T, c1, c2, Q, Tpeak, k, Ac, Ea, delta, mol, TgJump, T0, Tf

    !activation energy for curation
    Ea = 1000.0
    !amount present in the sample to cure
    mol = 0.6
    !chemicals A and B; proxy DGEBA-DDM, reaction ratio 
    A = 2.0
    B = 1.0

    !vitreous transition temperature for the resin, size of jump
    Tg = 60.0
    TgJump = 1.0

    !temperature for which a curation reaction starts occuring
    Tr = 120.0
    !peak reaction temperature
    Tpeak = 164.0


    !temperature scanning range
    T0 = 0.0
    Tf = 300.0

    !temperature variable
    T = T0

    !heat coeficient before and after vitreous transition
    c1 = 0.01
    c2 = 0.015

    A = A*mol
    B = B*mol

    !enthalpy for curation reaction
    dh = -10000.0

    !heat flow function y(0)
    Q = 13.0

    !output file
    open(1100, file="dsc1.dat", status="new")

    !scanning range loop
    do

      !specific heat
      if (T < Tg) then
        Q = Q + c1
      else
        Q = Q + c2
      end if

      !vitreous transition heat
      if (abs(T-Tg) < 15) then
        Q = Q + TgJump*1/dble(1+abs(T-Tg))
      end if

      !curation reaction heat
      if (T > Tg .and. A > 0 .and. B > 0) then

        !collision frequency factor
        Ac = exp(-(T-Tpeak)**2 / (2*Tpeak - 2*Tr)**1.7)
        !kinetic reaction factor
        k = Ac*exp(-Ea/T)

        print *, k, A, B

        !reaction
        A = 1/dble(1/A + k)
        delta = exp(log(B)-k) !amount
        B = exp(log(B)-k)
      else
        k = 0d0
      end if

      !log
      write(1100, *) T, Q + dh*k*delta

      if (T > Tf) exit
      T = T + 1
    end do


    close(1100)


end program
