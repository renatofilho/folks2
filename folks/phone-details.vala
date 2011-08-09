/*
 * Copyright (C) 2011 Collabora Ltd.
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *       Marco Barisione <marco.barisione@collabora.co.uk>
 *       Raul Gutierrez Segales <raul.gutierrez.segales@collabora.co.uk>
 */

using GLib;
using Gee;

/**
 * Object representing a phone number that can have some parameters associated
 * with it.
 *
 * See {@link Folks.AbstractFieldDetails} for details on common parameter names
 * and values.
 *
 * @since UNRELEASED
 */
public class Folks.PhoneFieldDetails : AbstractFieldDetails<string>
{
  private const string[] _extension_chars = { "p", "P", "w", "W", "x", "X" };
  private const string[] _common_delimiters = { ",", ".", "(", ")", "-", " ",
      "\t", "/" };
  private const string[] _valid_digits = { "#", "*", "0", "1", "2", "3", "4",
      "5", "6", "7", "8", "9" };

  /**
   * Create a new PhoneFieldDetails.
   *
   * @param value the value of the field
   * @param parameters initial parameters. See
   * {@link AbstractFieldDetails.parameters}. A `null` value is equivalent to a
   * empty map of parameters.
   *
   * @return a new PhoneFieldDetails
   *
   * @since UNRELEASED
   */
  public PhoneFieldDetails (string value,
      MultiMap<string, string>? parameters = null)
    {
      this.value = value;
      if (parameters != null)
        this.parameters = parameters;
    }

  /**
   * {@inheritDoc}
   *
   * @since UNRELEASED
   */
  public override bool equal (AbstractFieldDetails<string> that)
    {
      var that_fd = that as PhoneFieldDetails;

      if (that_fd == null)
        return false;

      var n1 = this._drop_extension (this.get_normalised ());
      var n2 = this._drop_extension (that_fd.get_normalised ());

      /* Based on http://blog.barisione.org/2010-06/handling-phone-numbers/ */
      if (n1.length >= 7 && n2.length >= 7)
        {
          var n1_reduced = n1.slice (-7, n1.length);
          var n2_reduced = n2.slice (-7, n2.length);

          debug ("[PhoneDetails.equal] Comparing %s with %s",
              n1_reduced, n2_reduced);

          return  n1_reduced == n2_reduced;
        }

      return n1 == n2;
    }

  /**
   * {@inheritDoc}
   *
   * @since UNRELEASED
   */
  public override uint hash ()
    {
      return base.hash ();
    }

  /**
   * Return this object's normalised phone number.
   *
   * Typical normalisations:
   *
   *  - `1-800-123-4567` → `18001234567`
   *  - `+1-800-123-4567` → `18001234567`
   *  - `+1-800-123-4567P123` → `18001234567P123`
   *
   * @return the normalised form of `number`
   *
   * @since UNRELEASED
   */
  public string get_normalised ()
    {
      string normalised_number = "";

      for (int i = 0; i < this.value.length; i++)
        {
          var digit = this.value.slice (i, i + 1);

          if (i == 0 && digit == "+")
            {
              /* we drop the initial + */
              continue;
            }
          else if (digit in this._extension_chars ||
              digit in this._valid_digits)
            {
              /* lets keep valid digits */
              normalised_number += digit;
            }
          else if (digit in this._common_delimiters)
            {
              continue;
            }
          else
            {
              debug ("[PhoneDetails.get_normalised] unknown digit: %s", digit);
            }
       }

      return normalised_number.up ();
    }

  /**
   * Returns the given number without its extension (if any).
   *
   * @param number the phone number to process
   * @return the number without its extension; if the number didn't have an
   * extension in the first place, the number is returned unmodified
   *
   * @since UNRELEASED
   */
  internal static string _drop_extension (string number)
    {
      for (var i = 0; i < PhoneFieldDetails._extension_chars.length; i++)
        {
          if (number.index_of (PhoneFieldDetails._extension_chars[i]) >= 0)
            {
              return number.split (PhoneFieldDetails._extension_chars[i])[0];
            }
        }

      return number;
    }
}

/**
 * Interface for classes that can provide a phone number, such as
 * {@link Persona} and {@link Individual}.
 *
 * @since 0.3.5
 */
public interface Folks.PhoneDetails : Object
{
  /**
   * The phone numbers of the contact.
   *
   * A list of phone numbers associated to the contact.
   *
   * @since UNRELEASED
   */
  public abstract Set<PhoneFieldDetails> phone_numbers { get; set; }
}
