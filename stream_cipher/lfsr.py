#!/usr/bin/env python

class LFSR(object):
    """
    A class representing a linear feedback shift register.
    """

    def __init__(self, state, polynomial):
        """
        Initialise the LFSR with the given state and polynomial.
        """

        # note that we copy the state to ensure we can mutate it
        self.state = state
        self.polynomial = polynomial

    def __iter__(self):
        """
        Implement the iterator protocol.
        """

        return self

    def next(self):
        """
        Return the next bit from the register and update the state.
        """

        # calculate the next bit we shift into the register
        new_bit = 0
        for tap in self.polynomial:
            new_bit ^= self.state[tap - 1]

        # insert the new bit, shifting all other bits along by one
        self.state.insert(0, new_bit)

        # return the bit that just dropped off the other end of the register
        return self.state.pop()


lfsr = LFSR([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], (4, 9, 10, 13))  # LFSR1 = 13 bits
# lfsr = LFSR([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], (3, 5, 7, 8))    # LFSR2 = 8 bits
# lfsr = LFSR([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], (1, 3, 4, 5))    # LFSR3 = 5 bits

print("LFSR1")
print("-----")
print("  state     : {0}".format(lfsr.state))
print("  polynomial: {0}".format(lfsr.polynomial))

for i in range(32):
    print(lfsr.next())