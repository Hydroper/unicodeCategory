package org.unicode.utils
{
    import flash.utils.ByteArray
    import flash.utils.Endian

    public final class UnicodeCategory
    {
        [Embed(
            source = '../octetStreamGenerator/output/generatedBMP.bin',
            mimeType = 'application/octet-stream'
        )]
        static private const bmpPlaneClass:Class
        static private const bmpPlane:ByteArray = new bmpPlaneClass as ByteArray
        bmpPlane.endian = Endian.LITTLE_ENDIAN;

        [Embed(
            source = '../octetStreamGenerator/output/generatedSP.bin',
            mimeType = 'application/octet-stream'
        )]
        static private const smpPlaneClass:Class
        static private const smpPlane:ByteArray = new smpPlaneClass as ByteArray
        smpPlane.endian = Endian.LITTLE_ENDIAN

        static public const
            CONTROL_OTHER             :uint = 0x00, // Cc
            FORMAT_OTHER              :uint = 0x01, // Cf
            PRIVATE_USE_OTHER         :uint = 0x02, // Co
            SURROGATE_OTHER           :uint = 0x03, // Cs
            NOT_ASSIGNED_OTHER        :uint = 0x04  // Cn

        static public const
            LOWERCASE_LETTER          :uint = 0x10,     // Ll
            MODIFIER_LETTER           :uint = 0x10 + 1, // Lm
            OTHER_LETTER              :uint = 0x10 + 2, // Lo
            TITLECASE_LETTER          :uint = 0x10 + 3, // Lt
            UPPERCASE_LETTER          :uint = 0x10 + 4  // Lu

        static public const
            COMBINING_SPACING_MARK    :uint = 0x20,     // Mc
            ENCLOSING_MARK            :uint = 0x20 + 1, // Me
            NON_SPACING_MARK          :uint = 0x20 + 2  // Mn

        static public const
            DECIMAL_NUMBER            :uint = 0x40,      // Nd
            LETTER_NUMBER             :uint = 0x40 + 1,  // Nl
            OTHER_NUMBER              :uint = 0x40 + 2,  // No
            CONNECTOR_PUNCTUATION     :uint = 0x40 + 3,  // Pc
            DASH_PUNCTUATION          :uint = 0x40 + 4,  // Pd
            OPEN_PUNCTUATION          :uint = 0x40 + 5,  // Ps
            CLOSE_PUNCTUATION         :uint = 0x40 + 6,  // Pe
            INITIAL_QUOTE_PUNCTUATION :uint = 0x40 + 7,  // Pi
            FINAL_QUOTE_PUNCTUATION   :uint = 0x40 + 8,  // Pf
            OTHER_PUNCTUATION         :uint = 0x40 + 9,  // Po
            CURRENCY_SYMBOL           :uint = 0x40 + 10, // Sc
            MODIFIER_SYMBOL           :uint = 0x40 + 11, // Sk
            MATH_SYMBOL               :uint = 0x40 + 12, // Sm
            OTHER_SYMBOL              :uint = 0x40 + 13, // So
            LINE_SEPARATOR            :uint = 0x40 + 14, // Zl
            PARAGRAPH_SEPARATOR       :uint = 0x40 + 15, // Zp
            SPACE_SEPARATOR           :uint = 0x40 + 16  // Zs

        static public function fromString(s:String):uint
        {
            return fromCharCode(UnicodeSurrogate.charCodeAt(s, 0))
        }

        static public function fromCharCode(cp:uint):uint
        {
            if (cp >> 16 !== 0)
                return smpPlaneAgainst(cp, 0)
            else {
                const start:uint =
                    ! ( cp >> 8 )                           ? 0   :
                      ( cp < 0x376   && cp >= 0x100 )       ? 218 :
                      ( cp < 0x800   && cp >= 0x376 )       ? 1219 :
                      ( cp < 0x1000  && cp >= 0x800 )       ? 2323 :
                      ( cp < 0x2016  && cp >= 0x1000 )      ? 3643 :
                      ( cp < 0x3000  && cp >= 0x2016 )      ? 5688 :
                      ( cp < 0x4E00  && cp >= 0x3000 )      ? 7166 :
                      ( cp < 0xA000  && cp >= 0x4E00 )      ? 7452 :
                      ( cp < 0xAC00  && cp >= 0xA000 )      ? 7458 :
                      ( cp < 0xF900  && cp >= 0xAC00 )      ? 8790 : 8827

                return bmpPlaneAgainst(cp, start)
            }
        }

        [Inline]
        static public function isOther(gc:uint):Boolean
        {
            return !(gc >> 4)
        }

        [Inline]
        static public function isLetter(gc:uint):Boolean
        {
            return gc >> 4 === 1
        }

        [Inline]
        static public function isMark(gc:uint):Boolean
        {
            return gc >> 5 === 1
        }

        [Inline]
        static public function isNumber(gc:uint):Boolean
        {
            return gc >> 6 === 1 && gc < CONNECTOR_PUNCTUATION
        }

        [Inline]
        static public function isPunctuation(gc:uint):Boolean
        {
            return gc >> 6 === 1 && gc > OTHER_NUMBER && gc < CURRENCY_SYMBOL
        }

        [Inline]
        static public function isSymbol(gc:uint):Boolean
        {
            return gc >> 6 === 1 && gc > OTHER_PUNCTUATION && gc < LINE_SEPARATOR
        }

        [Inline]
        static public function isSeparator(gc:uint):Boolean
        {
            return gc >> 6 === 1 && gc > OTHER_SYMBOL
        }

        static private function bmpPlaneAgainst(cp:uint, start:uint):uint
        {
            bmpPlane.position = start
            var lead:uint
            while (bmpPlane.position !== bmpPlane.length)
            {
                lead = bmpPlane.readUnsignedByte()
                if (lead >> 7 === 1)
                {
                    lead &= 0x7F
                    if (cp === bmpPlane.readUnsignedShort()) return lead
                }
                else
                {
                    if (cp <  bmpPlane.readUnsignedShort()) break 
                    if (cp <= bmpPlane.readUnsignedShort()) return lead
                }
            }
            return NOT_ASSIGNED_OTHER
        }

        static private function smpPlaneAgainst(cp:uint, start:uint):uint {
            smpPlane.position = start
            var lead:uint
            while (smpPlane.position !== smpPlane.length) {
                lead = smpPlane.readUnsignedByte()
                if (lead >> 7 === 1) {
                    lead &= 0x7F
                    if (cp === readUint24(smpPlane)) return lead
                } else {
                    if (cp <  readUint24(smpPlane)) break
                    if (cp <= readUint24(smpPlane)) return lead
                }
            }
            return NOT_ASSIGNED_OTHER
        }

        [Inline]
        static private function readUint24(ba:ByteArray):uint {
            return ba.readUnsignedShort()
                 | (ba.readUnsignedByte() << 16)
        }
    }
}