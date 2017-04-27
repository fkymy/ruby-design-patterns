### Proxy

Controlling access to an object or providing a location-independent way of getting at the object or delaying its creation.

> Proxy is essentially built around a little white lie.

Situation:
Bank account object that clients ask for, but we instead return an object that looks and acts like the real objet, but actually is an imposter. Handing proxy object, which has a reference to the subject hidden inside.

```eg.rb
class BankAccount
  attr_reader :balance

  def initialize(starting_balance=0)
    @balance = starting_balance
  end

  def deposit(amount)
    @balance += amount
  end

  def withdraw(amount)
    @balance -= amount
  end
end

class BankAccountProxy
  def initialize(real_object)
    @real_object = real_object
  end

  def balance
    @real_object.balance
  end

  def deposit(amount)
    @real_object.deposit(amount)
  end

  def withdraw(amount)
    @real_object.withdraw(amount)
  end
end

# account = BankAccount.new(100)
# account.deposit(50)
# account.withdraw(10)
# proxy = BankAccountProxy.new(account)
# proxy.deposit(50)
# proxy.withdraw(10)
```

#### Protection Proxy
Protection proxy controls access to the subject:

```protection.rb
require 'etc'

class AccountProtectionProxy
  def initialize(real_account, owner_name)
    @subject = real_account
    @owner_name = owner_name
  end

  def deposit(amount)
    check_access
    return @subject.deposit(amount)
  end

  def withdraw(amount)
    check_access
    return @subject.withdraw(amount)
  end

  def balance
    check_access
    return @subject.balance
  end

  def check_access
    if Etc.getlogin != @owner_name
      raise "Illegal access: #{Etc.getlogin} cannot access account."
    end
  end
end
```

Advantages:
- A separation of concerns: the proxy worries about who is or is not allowed to do what, and the real account only need to be concerned with the bank account.
- Security layer can be swapped with other security schemes, or eliminate it when necessary.

#### Remote Proxy

If the concern is not the security but the location of the object, consider Remote Proxies. A great example of a remote proxy is Distributed Ruby (DRb), which allows Ruby programs to communicate over a network. With DRb, the client machines runs a proxy which handles all of the network communications behind the scenes.

#### Virtual Proxy

If the concern is delaying creation of expensive objects until the point we really need them, consider Virtual Proxies.

```virtual.rb
class VirtualAccountProxy
  def initialize(starting_balance=0)
    @starting_balance=starting_balance
  end

  def deposit(amount)
    s = subject
    return s.deposit(amount)
  end

  def withdraw(amount)
    s = subject
    return s.withdraw(amount)
  end

  def balance
    s = subject
    return s.balance
  end

  def subject
    @subject || (@subject = BankAccount.new(@starting_balance))
  end
end
```

^The subject method is key, and it can be implemented in many situations.

One drawback is that the proxy is responsible for creating the object itself, and it tangles the proxy and the subject up. Maybe just implement the subject method, or if you want, use code block:

```block.rb
class VirtualAccountProxy
  def initialize(&creation_block)
    @creation_block = creation_block
  end

  def deposit(amount)
    s = subject
    s.deposit(amount)
  end

  def withdraw(amount)
    s = subject
    s.withdraw(amount)
  end

  def balance
    s = subject
    s.balance
  end

  def subject
    @subject || (@subject = @creation_block.call)
  end
```

`account = VirtualAccountProxy.new { BankAccount.new(10) }`

#### Message passing
https://gist.github.com/fkymy/678d1fdf1e0b9504b93a9aa987fd1c30
