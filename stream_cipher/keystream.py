#!/usr/bin/env python

import copy
import itertools

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


class Keystream(object):
    """
    A class representing a keystream generator.
    """

    def __init__(self, lfsr1, lfsr2, lfsr3):
        """
        Initialise the keystream with the given LFSR states.
        """

        # make copies of the LFSRs as we'll be mutating their state
        self.lfsr1 = copy.deepcopy(lfsr1)
        self.lfsr2 = copy.deepcopy(lfsr2)
        self.lfsr3 = copy.deepcopy(lfsr3)

    def __iter__(self):
        """
        Implement the iterator protocol.
        """

        return self

    def next(self):
        """
        Generate and output the next bit.
        """

        # Step each of the LFSRs, catching the bits that are shifted out
        x = self.lfsr1.next()
        y = self.lfsr2.next()
        z = self.lfsr3.next()

        # Combine the LFSR bits using the Geffe combining function. This has
        # the following truth table:
        #
        # +----------------------+
        # | X | Y | Z | F(X,Y,Z) |
        # +----------------------+
        # | 0 | 0 | 0 |     0    |
        # | 0 | 0 | 1 |     1    |
        # | 0 | 1 | 0 |     0    |
        # | 0 | 1 | 1 |     1    |
        # | 1 | 0 | 0 |     0    |
        # | 1 | 0 | 1 |     0    |
        # | 1 | 1 | 0 |     1    |
        # | 1 | 1 | 1 |     1    |
        # +----------------------+
        #
        return ((x & y) ^ (~x & z))

lfsr1 = LFSR([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], (4, 9, 10, 13))  # LFSR1 = 13 bits
lfsr2 = LFSR([0, 0, 0, 0, 0, 0, 0, 1],                (3, 5, 7, 8))    # LFSR2 = 8 bits
lfsr3 = LFSR([0, 1, 1, 1, 0],                         (1, 3, 4, 5))    # LFSR3 = 5 bits

print("LFSR1")
print("-----")
print("  state     : {0}".format(lfsr1.state))
print("  polynomial: {0}".format(lfsr1.polynomial))

print("LFSR2")
print("-----")
print("  state     : {0}".format(lfsr2.state))
print("  polynomial: {0}".format(lfsr2.polynomial))

print("LFSR3")
print("-----")
print("  state     : {0}".format(lfsr3.state))
print("  polynomial: {0}".format(lfsr3.polynomial))

keystream = Keystream(lfsr1, lfsr2, lfsr3)

for i in range(32):
    print(keystream.next())