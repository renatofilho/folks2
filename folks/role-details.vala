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
 *       Raul Gutierrez Segales <raul.gutierrez.segales@collabora.co.uk>
 *       Travis Reitter <travis.reitter@collabora.co.uk>
 */

using Gee;
using GLib;

/**
 * This interface represents the role a {@link Persona} and {@link Individual}
 * have in a given Organisation.
 *
 * @since 0.4.0
 */
public class Folks.Role : Object
{
  /**
   * The name of the organisation in which the role is held.
   */
  public string organisation_name { get; set; }

  /**
   * The title of the position held.
   *
   * For example: “Director, Ministry of Silly Walks”
   */
  public string title { get; set; }

  /**
   * The role of the position.
   *
   * For example: “Programmer”
   *
   * @since UNRELEASED
   */
  public string role { get; set; }

  /**
   * The UID that distinguishes this role.
   */
  public string uid { get; set; }

  /**
   * Default constructor.
   *
   * @param title title of the position
   * @param organisation_name organisation where the role is hold
   * @param uid a Unique ID associated to this Role
   * @return a new Role
   *
   * @since 0.4.0
   */
  public Role (string? title = null,
      string? organisation_name = null, string? uid = null)
    {
      if (title == null)
        {
          title = "";
        }

      if (organisation_name == null)
        {
          organisation_name = "";
        }

      if (uid == null)
        {
          uid = "";
        }

      Object (uid:                  uid,
              title:                title,
              organisation_name:    organisation_name);
    }

  /**
   * Compare if two roles are equal. Roles are equal if their titles and
   * organisation names are equal.
   *
   * @param a a role to compare
   * @param b another role to compare
   * @return `true` if the roles are equal, `false` otherwise
   */
  public static bool equal (Role a, Role b)
    {
      return (a.title == b.title) &&
          (a.role == b.role) &&
          (a.organisation_name == b.organisation_name);
    }

  /**
   * Hash function for the class. Suitable for use as a hash table key.
   *
   * @param r a role to hash
   * @return hash value for the role instance
   */
  public static uint hash (Role r)
    {
      return r.organisation_name.hash () ^ r.title.hash () ^ r.role.hash ();
    }

  /**
   * Formatted version of this role.
   *
   * @since 0.4.0
   */
  public string to_string ()
    {
      var str = _("Title: %s, Organisation: %s, Role: %s");
      return str.printf (this.title, this.organisation_name, this.role);
    }
}

/**
 * Object representing details of a contact in an organisation which can have
 * some parameters associated with it.
 *
 * See {@link Folks.AbstractFieldDetails}.
 *
 * @since UNRELEASED
 */
public class Folks.RoleFieldDetails : AbstractFieldDetails<Role>
{
  /**
   * Create a new RoleFieldDetails.
   *
   * @param value the {@link Role} of the field
   * @param parameters initial parameters. See
   * {@link AbstractFieldDetails.parameters}. A `null` value is equivalent to an
   * empty map of parameters.
   *
   * @return a new RoleFieldDetails
   *
   * @since UNRELEASED
   */
  public RoleFieldDetails (Role value,
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
      var that_fd = that as RoleFieldDetails;

      if (that_fd == null)
        return false;

      return Role.equal (this.value, that_fd.value);
    }

  /**
   * {@inheritDoc}
   *
   * @since UNRELEASED
   */
  public override uint hash ()
    {
      return str_hash (this.value.to_string ());
    }
}

/**
 * This interfaces represents the list of roles a {@link Persona} and
 * {@link Individual} might have.
 *
 * @since 0.4.0
 */
public interface Folks.RoleDetails : Object
{
  /**
   * The roles of the contact.
   *
   * @since UNRELEASED
   */
  public abstract Set<RoleFieldDetails> roles { get; set; }
}
