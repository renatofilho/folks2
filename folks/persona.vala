/*
 * Copyright (C) 2010 Collabora Ltd.
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
 *       Travis Reitter <travis.reitter@collabora.co.uk>
 */

using GLib;
using Folks;

/**
 * Represents a "shard" of a person from a single source (a single
 * {@link Backend}), such as an XMPP contact from Telepathy or a vCard contact
 * from evolution-data-server. All the personas belonging to one physical person
 * are aggregated to form a single {@link Individual} representing that person.
 */
public abstract class Folks.Persona : Object
{
  /**
   * The internal ID used to represent the Persona within its {@link Backend}.
   *
   * This should not be used by client code.
   */
  public string iid { get; construct; }

  /**
   * The universal ID used to represent the Persona outside its {@link Backend}.
   *
   * For example: `foo@@xmpp.example.org`.
   *
   * This is the canonical way to refer to any Persona. It is guaranteed to be
   * unique within the Persona's {@link PersonaStore}.
   */
  public string uid { get; construct; }

  /**
   * The {@link PersonaStore} which contains this Persona.
   */
  public weak PersonaStore store { get; construct; }

  /**
   * The names of the properties of this Persona which are linkable.
   *
   * If a property name is in this list, and the Persona is from a
   * {@link PersonaStore} whose trust level is {@link PersonaStoreTrust.FULL},
   * the {@link IndividualAggregator} should be able to reliably use the value
   * of the property from a given Persona instance to link the Persona with
   * other Personas and form {@link Individual}s.
   *
   * Note that {@link Persona.uid} is always implicitly a member of this list,
   * and doesn't need to be added explicitly.
   *
   * This list will have no effect if the Persona's {@link PersonaStore} trust
   * level is not {@link PersonaStoreTrust.FULL}.
   */
  public string[] linkable_properties { get; protected set; }
}
