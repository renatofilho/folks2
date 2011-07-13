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
 * Authors: Raul Gutierrez Segales <raul.gutierrez.segales@collabora.co.uk>
 *
 */

using EdsTest;
using Folks;
using Gee;

public class IndividualRetrievalTests : Folks.TestCase
{
  private EdsTest.Backend _eds_backend;
  private GLib.MainLoop _main_loop;
  private IndividualAggregator _aggregator;
  private HashSet<string> _found_individuals;

  public IndividualRetrievalTests ()
    {
      base ("IndividualRetrieval");

      this._eds_backend = new EdsTest.Backend ();

      this.add_test ("singleton individuals", this.test_singleton_individuals);
    }

  public override void set_up ()
    {
      this._eds_backend.set_up ();
    }

  public override void tear_down ()
    {
      this._eds_backend.tear_down ();
    }

  public void test_singleton_individuals ()
    {
      Gee.HashMap<string, Value?> c1 = new Gee.HashMap<string, Value?> ();
      Gee.HashMap<string, Value?> c2 = new Gee.HashMap<string, Value?> ();
      this._found_individuals = new HashSet<string> (str_hash,
          str_equal);
      this._main_loop = new GLib.MainLoop (null, false);
      Value? v;

      this._eds_backend.reset();

      v = Value (typeof (string));
      v.set_string ("bernie h. innocenti");
      c1.set("full_name", (owned) v);
      v = Value (typeof (string));
      v.set_string ("bernie@example.org");
      c1.set(Edsf.Persona.email_fields[0], (owned) v);
      this._eds_backend.add_contact (c1);

      v = Value (typeof (string));
      v.set_string ("richard m. stallman");
      c2.set("full_name", (owned) v);
      v = Value (typeof (string));
      v.set_string ("rms@example.org");
      c2.set(Edsf.Persona.email_fields[0], (owned) v);
      this._eds_backend.add_contact (c2);

      this._test_singleton_individuals_async ();

      Timeout.add_seconds (5, () =>
        {
          this._main_loop.quit ();
          return false;
        });

      this._main_loop.run ();

      assert (this._found_individuals.size == 2);
    }

  private async void _test_singleton_individuals_async ()
    {

      yield this._eds_backend.commit_contacts_to_addressbook ();

      var store = BackendStore.dup ();
      yield store.prepare ();
      this._aggregator = new IndividualAggregator ();
      this._aggregator.individuals_changed.connect
          (this._individuals_changed_cb);
      try
        {
          yield this._aggregator.prepare ();
        }
      catch (GLib.Error e)
        {
          GLib.warning ("Error when calling prepare: %s\n", e.message);
        }
    }

  private void _individuals_changed_cb
      (Set<Individual> added,
       Set<Individual> removed,
       string? message,
       Persona? actor,
       GroupDetails.ChangeReason reason)
    {
      foreach (Individual i in added)
        {
          assert (i.personas.size == 1);
          this._found_individuals.add (i.id);
        }

      if (this._found_individuals.size == 2)
        {
          this._main_loop.quit ();
        }

      assert (removed.size == 0);
    }
}

public int main (string[] args)
{
  Test.init (ref args);

  TestSuite root = TestSuite.get_root ();
  root.add_suite (new IndividualRetrievalTests ().get_suite ());

  Test.run ();

  return 0;
}