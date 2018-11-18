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
        self.state = list(state)
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


class StreamCipher(object):
    """
    A class encapsulating a stream cipher, encrypting/decrypting messages a
    single bit at a time.
    """

    @staticmethod
    def encrypt(plaintext, keystream):
        """
        Returns a generator object which encrypts the given plaintext using the
        provided keystream.
        """

        # Helper method to return the bits in a byte, least-significant first
        def bits(byte):
            for _ in range(8):
                yield byte & 1
                byte >>= 1

        # Return a generator that iterates over each character in the message,
        # bit-by-bit, XORing each bit with the next bit of the keystream.
        return (bit ^ keystream.next() for char in plaintext
                                       for bit in bits(ord(char)))

    @staticmethod
    def decrypt(ciphertext, keystream):
        """
        Returns a generator object which decrypts the given ciphertext using the
        provided keystream.
        """

        # decrypt each of the bits in the ciphertext stream
        plaintext_bits = (int(bit) ^ keystream.next() for bit in ciphertext)

        # recombine the plaintext bits into ASCII characters
        char_bits = []
        for bit in plaintext_bits:
            char_bits.append(str(bit))
            if len(char_bits) == 8:
                yield chr(int(''.join(reversed(char_bits)), 2))
                char_bits = []


if __name__ == "__main__":

    # read in the plaintext
    with open('plaintext.txt', 'r') as f:
        plaintext = f.read()

    # Construct the LFSRs using their initial states and the specified
    # polynomials. The polynomial defines the tap bits used to calculate the new
    # bit to shift in each iteration.
    lfsr1 = LFSR([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], (4, 9, 10, 13))   # LFSR1 = 13 bits
    lfsr2 = LFSR([0, 0, 0, 0, 0, 0, 0, 0], (3, 5, 7, 8))                    # LFSR2 = 8 bits
    lfsr3 = LFSR([0, 0, 0, 0, 0], (1, 3, 4, 5))                             # LFSR3 = 5 bits

    # dump out the initial LFSR states and polynomials
    print("LFSR1")
    print("-----")
    print("  state     : {0}".format(lfsr1.state))
    print("  polynomial: {0}".format(lfsr1.polynomial))
    print("")
    print("LFSR2")
    print("-----")
    print("  state     : {0}".format(lfsr2.state))
    print("  polynomial: {0}".format(lfsr2.polynomial))
    print("")
    print("LFSR3")
    print("-----")
    print("  state     : {0}".format(lfsr3.state))
    print("  polynomial: {0}".format(lfsr3.polynomial))

    # encrypt the plaintext
    print("")
    print("Encrypting ..."),
    encryptor = StreamCipher.encrypt(plaintext, Keystream(lfsr1, lfsr2, lfsr3))
    ciphertext = ''.join(itertools.imap(str, encryptor))

    # do a sanity check to ensure the recovered plaintext matches the original
    decryptor = StreamCipher.decrypt(ciphertext, Keystream(lfsr1, lfsr2, lfsr3))
    plaintext_test = ''.join(decryptor)
    if plaintext_test != plaintext:
        exit("error: recovered plaintext does not match original!")

    # if we round-tripped the plaintext successfully, write out the ciphertext
    with open('ciphertext.bits', 'wb') as f:
        f.write(ciphertext)

    print("Ciphertext written successfully!")
