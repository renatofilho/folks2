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

using Folks;
using Gee;

public class ImDetailsTests : Folks.TestCase
{
  private EdsTest.Backend _eds_backend;
  private GLib.MainLoop _main_loop;
  private IndividualAggregator _aggregator;
  private int _num_addrs;
  private bool _found_addr_1;
  private bool _found_addr_2;
  private string _fullname;
  private string _im_addrs;

  public ImDetailsTests ()
    {
      base ("ImDetailsTests");

      this._eds_backend = new EdsTest.Backend ();

      this.add_test ("test im details interface",
          this.test_im_details_interface);
    }

  public override void set_up ()
    {
      this._eds_backend.set_up ();
    }

  public override void tear_down ()
    {
      this._eds_backend.tear_down ();
    }

  public void test_im_details_interface ()
    {
      this._main_loop = new GLib.MainLoop (null, false);
      Gee.HashMap<string, Value?> c1 = new Gee.HashMap<string, Value?> ();
      this._fullname = "persona #1";
      this._im_addrs = "im_jabber_home_1#test1@example.org";
      this._im_addrs += ",im_yahoo_home_1#test2@example.org";
      Value? v;

      this._eds_backend.reset();

      v = Value (typeof (string));
      v.set_string (this._fullname);
      c1.set ("full_name", (owned) v);
      v = Value (typeof (string));
      v.set_string (this._im_addrs);
      c1.set ("im_addresses", (owned) v);

      this._eds_backend.add_contact (c1);

      this._num_addrs = 0;
      this._found_addr_1 = false;
      this._found_addr_2 = false;

      this._test_im_details_interface_async ();

      Timeout.add_seconds (5, () =>
        {
          this._main_loop.quit ();
          assert_not_reached ();
        });

      this._main_loop.run ();

      assert (this._num_addrs == 2);
      assert (this._found_addr_1 == true);
      assert (this._found_addr_2 == true);
    }

  private async void _test_im_details_interface_async ()
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
      foreach (var i in added)
        {
          string full_name = i.full_name;
          if (full_name == this._fullname)
            {
              foreach (var proto in i.im_addresses.get_keys ())
                {
                  var addrs = i.im_addresses.get (proto);

                 if (proto == "jabber")
                    {
                      if (addrs.contains ("test1@example.org"))
                        {
                          this._found_addr_1 = true;
                          this._num_addrs++;
                        }
                    }
                  else if (proto == "yahoo")
                    {
                      if (addrs.contains ("test2@example.org"))
                        {
                          this._found_addr_2 = true;
                          this._num_addrs++;
                        }
                    }
                }
            }
        }

      assert (removed.size == 0);

      if (this._num_addrs == 2 &&
          this._found_addr_1 == true &&
          this._found_addr_2 == true)
        this._main_loop.quit ();
    }
}

public int main (string[] args)
{
  Test.init (ref args);

  TestSuite root = TestSuite.get_root ();
  root.add_suite (new ImDetailsTests ().get_suite ());

  Test.run ();

  return 0;
}